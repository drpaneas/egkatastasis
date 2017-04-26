Instructions
############

.. code:: bash

    zypper -n in docker gnu_parallel
    systemctl start docker.service
    systemctl enable docker.service

Create a `BTRFS subvolume` called `test_tw` using the opensuse:tumbleweed
image:

.. code:: bash

    btrfs subvolume create /var/lib/machines/test_tw
    docker export "$(docker create --name test_tw opensuse:tumbleweed true)" | tar -x -C /var/lib/machines/test_tw

Optionally, feel free to remove the docker image, in order to free some space:

.. code:: bash

    docker rm test_tw

Setting root pass is not needed, but it's a good practice in case you want to
login and configure your base container:

.. code:: bash

    /usr/bin/systemd-nspawn --machine=test_tw --directory=/var/lib/machines/test_tw/ passwd

Then, login and install `systemd` package:

.. code:: bash

    /usr/bin/systemd-nspawn --machine=test_tw --directory=/var/lib/machines/test_tw/ /bin/bash
    zypper in systemd

After the `systemd installation`, let's make sure that it works. Exit and boot
back again using the `--boot` parameter:

.. code:: bash

    /usr/bin/systemd-nspawn --machine=test_tw --directory=/var/lib/machines/test_tw/ --boot

Alright, now let's install some more packages:

.. code:: bash

    zypper in bind-utils ntp openssh glibc-i18ndata dbus-1 net-tools vim which wget net-tools-deprecated wicked

Reboot it using `systemd`:

.. code:: bash

    systemctl reboot

Login back again, and fix the problem with the `timezone`:

.. code:: bash

    /usr/bin/systemd-nspawn --machine=test_tw --directory=/var/lib/machines/test_tw/ --boot
    timedatectl set-timezone Europe/Berlin
    sed -i '/en_US.UTF-8/c\RC_LANG=""' /etc/sysconfig/language

Last but not least, enable `ssh` or any other service you might want:

.. code:: bash

    systemctl enable sshd
    systemctl start sshd

If you like, you can use my `motd - Message Of The Day`:

.. code:: bash

    wget --no-check-certificate https://gitlab.suse.de/pgeorgiadis/TaaS/raw/master/motd.sh -O /etc/motd.sh
    bash /etc/motd.sh

Spawn ephemeral containers
##########################

Now that we have a base container, we are going to use this as the standard
template for generating/spawning ephemeral ones. First of all, let's enable it
to start on boot:

.. code:: bash

    systemctl enable systemd-nspawn@test_tw

Just to be one the safe side, backup the `*.service` file:

.. code:: bash

    cp /usr/lib/systemd/system/systemd-nspawn@.service /usr/lib/systemd/system/systemd-nspawn@.service.old

And change it into this:

.. code:: bash

    # cat /usr/lib/systemd/system/systemd-nspawn@.service

    #  This file is part of systemd.
    #
    #  systemd is free software; you can redistribute it and/or modify it
    #  under the terms of the GNU Lesser General Public License as published by
    #  the Free Software Foundation; either version 2.1 of the License, or
    #  (at your option) any later version.

    [Unit]
    Description=Container %i
    Documentation=man:systemd-nspawn(1)
    PartOf=machines.target
    Before=machines.target
    After=network.target

    [Service]
    ExecStart=/usr/bin/systemd-nspawn --ephemeral --machine=%I --directory=/var/lib/machines/test_tw/ --boot
    KillMode=mixed
    Type=notify
    RestartForceExitStatus=133
    SuccessExitStatus=133
    Slice=machine.slice
    Delegate=yes
    TasksMax=16384

    # Enforce a strict device policy, similar to the one nspawn configures
    # when it allocates its own scope unit. Make sure to keep these
    # policies in sync if you change them!
    DevicePolicy=closed
    DeviceAllow=/dev/net/tun rwm
    DeviceAllow=char-pts rw

    # nspawn itself needs access to /dev/loop-control and /dev/loop, to
    # implement the --image= option. Add these here, too.
    DeviceAllow=/dev/loop-control rw
    DeviceAllow=block-loop rw
    DeviceAllow=block-blkext rw

    [Install]
    WantedBy=machines.target
    Also=dbus.service

Now, copy this into `tw@.service` template:

.. code:: bash

    cp /usr/lib/systemd/system/systemd-nspawn@.service /usr/lib/systemd/system/tw@.service

Start the container:
####################

.. code:: bash

    panos:~ # systemctl start tw@ 
    Display all 231 possibilities? (y or n)
    panos:~ # systemctl start tw@1.service
    panos:~ # systemctl status tw@1.service
    ● tw@1.service - Container 1
       Loaded: loaded (/usr/lib/systemd/system/tw@.service; disabled; vendor preset: disabled)
       Active: active (running) since Tue 2017-04-25 17:26:41 CEST; 5s ago
         Docs: man:systemd-nspawn(1)
     Main PID: 12288 (systemd-nspawn)
       Status: "Container running."
        Tasks: 1 (limit: 16384)
       Memory: 1.4M
          CPU: 17ms
       CGroup: /machine.slice/tw@1.service
               └─12288 /usr/bin/systemd-nspawn --ephemeral --network-macvlan=enp0s31f6 --machine=1 --directory=/var/lib/machines/test_tw/ --boot

    Apr 25 17:26:42 panos.suse.de systemd-nspawn[12288]: [  OK  ] Started /etc/init.d/boot.local Compatibility.
    Apr 25 17:26:42 panos.suse.de systemd-nspawn[12288]: [  OK  ] Started wicked DHCPv6 supplicant service.
    Apr 25 17:26:42 panos.suse.de systemd-nspawn[12288]: [  OK  ] Started wicked DHCPv4 supplicant service.
    Apr 25 17:26:42 panos.suse.de systemd-nspawn[12288]: [  OK  ] Started wicked AutoIPv4 supplicant service.
    Apr 25 17:26:42 panos.suse.de systemd-nspawn[12288]:          Starting wicked network management service daemon...
    Apr 25 17:26:42 panos.suse.de systemd-nspawn[12288]: [  OK  ] Started Login Service.
    Apr 25 17:26:42 panos.suse.de systemd-nspawn[12288]: [  OK  ] Started wicked network management service daemon.
    Apr 25 17:26:42 panos.suse.de systemd-nspawn[12288]:          Starting wicked network nanny service...
    Apr 25 17:26:42 panos.suse.de systemd-nspawn[12288]: [  OK  ] Started wicked network nanny service.
    Apr 25 17:26:42 panos.suse.de systemd-nspawn[12288]:          Starting wicked managed network interfaces...


You can monitor this also via `machinectl`:

.. code:: bash

    panos:~ # machinectl
    MACHINE CLASS     SERVICE        OS       VERSION  ADDRESSES
    1       container systemd-nspawn opensuse 20170420 10.160.65.125...

    1 machines listed.


Run a command and get its output
################################

Example:

.. code:: bash

    systemd-run --machine 1 /bin/sh -c "/usr/bin/zypper -n in vim"
    journalctl --machine 1 -u run-u19.service -b -q
