
# Tutorial

So far, there are two implementations:

* docker (not that great, but can work in Kubernetes)
* systemd-nspawn (better, but tooling isn't that great)

*Note: for system-nspawn: systemd >= 232 version is a hard requirement!*

Feel free to try both of them.

The target goal is to catch installation problems for the already released packages
(if there are any) such as dependency conflicts and ugly RPM additional outputs.

## Preparation

First of all you need to install the following software packages:

```bash
    # zypper -n in gnu_parallel bc docker docker-compose
```

Enable and start the Docker daemon:

```bash
    systemctl start docker.service
    systemctl enable docker.service
```

## Docker

Absolutely nothing. This is the benefit of Docker ecosystem and tooling.


## systemd-nspawn

**Note**: `systemd >= 232` version is a hard requirement!

Create a `BTRFS subvolume` called `test_tw` using the opensuse:tumbleweed
image:

```bash
    btrfs subvolume create /var/lib/machines/test_tw
    docker export "$(docker create --name test_tw opensuse:tumbleweed true)" | tar -x -C /var/lib/machines/test_tw
```

Optionally, feel free to remove the docker image, in order to free some space:

```bash
    docker rm test_tw
```

Setting root pass is not needed, but it's a good practice in case you want to
login and configure your base container:

```bash
    /usr/bin/systemd-nspawn --machine=test_tw --directory=/var/lib/machines/test_tw/ passwd
```

Then, login and install `systemd` package:

```bash
    /usr/bin/systemd-nspawn --machine=test_tw --directory=/var/lib/machines/test_tw/ /bin/bash
    zypper in systemd
```

After the `systemd installation`, let's make sure that it works. Exit and boot
back again using the `--boot` parameter:

```bash
    /usr/bin/systemd-nspawn --machine=test_tw --directory=/var/lib/machines/test_tw/ --boot
```

Alright, now let's install some more packages:

```bash
    zypper in bind-utils ntp openssh glibc-i18ndata dbus-1 net-tools vim which wget net-tools-deprecated wicked
```

Reboot it using `systemd`:

```bash
    systemctl reboot
```

Login back again, and fix the problem with the `timezone`:

```bash
    /usr/bin/systemd-nspawn --machine=test_tw --directory=/var/lib/machines/test_tw/ --boot
    timedatectl set-timezone Europe/Berlin
    sed -i '/en_US.UTF-8/c\RC_LANG=""' /etc/sysconfig/language
```


#### Spawn ephemeral containers

Now that we have a base container, we are going to use this as the standard
template for generating/spawning ephemeral ones. First of all, let's enable it
to start on boot:

```bash
    systemctl enable systemd-nspawn@test_tw
```

Just to be one the safe side, backup the `*.service` file:

```bash
cp /usr/lib/systemd/system/systemd-nspawn@.service /usr/lib/systemd/system/systemd-nspawn@.service.old
```
And change it into this:

```bash
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
```

Now, copy this into `tw@.service` template:

```bash
    cp /usr/lib/systemd/system/systemd-nspawn@.service /usr/lib/systemd/system/tw@.service
```

#### Start the container:

```bash

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
```

You can monitor this also via `machinectl`:

```bash
    panos:~ # machinectl
    MACHINE CLASS     SERVICE        OS       VERSION  ADDRESSES
    1       container systemd-nspawn opensuse 20170420 10.160.65.125...

    1 machines listed.
```

#### Run a command and get its output

Example:

```bash
    systemd-run --machine 1 /bin/sh -c "/usr/bin/zypper -n in vim"
    journalctl --machine 1 -u run-u19.service -b -q
```

## Run (both docker and systemd)

Then you need to create a file called `packages.txt` which will consist of the
packages you would like to test. This file can be automatically generated using
the `fetch_pkglist.sh` script.

```bash
    ./fetch_pkglist.sh
```

As soon as the `packages.txt` has been populated, then you can start your test
by running the `test_all_parallel.sh` script.

```bash
    ./test_all_parallel.sh
```

If you like to test packages against specific architectures (by default all
architectures are tests) you can provide the architecture type as argument:

```bash
    ./test_all_parallel.sh x86_64
```

* Supported arguments are: `x86_64`, `i586`, `i686`, `noarch`.

In case you would like to monitor the current status while the test is running,
then you can use the `monitor.sh` script.

```bash
    ./monitor.sh
```

In case you are testing against a specific architecture, then you must specify
this also here as an argument:

```bash
    ./monitor.sh x86_64
```

* Supported arguments are: `x86_64`, `i586`, `i686`, `noarch`.

Last but not least, some kind of parsing can be achieved via `parser.sh`.

```bash
    ./parser.sh
```

### Rerun


Delete the `.log` and `list.` files

```bash
    rm *.list
    rm *.log
```

## ELK Stack

First of all clone the project:

```bash
    git clone https://github.com/drpaneas/egkatastasis
```

Then change directory into `egkatastasis` root folder:

```bash
    cd egkatastasis/
```

Start ElasticSearch:

```bash
    sudo docker run -d -p 9200:9200 -p 9300:9300 -it -h elasticsearch --name elasticsearch elasticsearch
```

Start Kibana:

```bash
    sudo docker run -d -p 5601:5601 -h kibana --name kibana --link elasticsearch:elasticsearch kibana
```

Then start testing and generate some logs using either the Docker or the
systemd-nspawn container. As soon as you have initiated the testing process
you can now start `logstash`. In the following examples, we are taking as
granted the fact that the logs are stored locally in either `./egkatastasis/docker/` for *Docker*
or in `./egkatastasis/systemd-nspawn/` directory for *systemd-nspawn*.

Start Logstash:

Depending on which method you have chosen (Docker or SystemD) run the following commands:

For **systemd-nspawn**:

```bash

    sudo docker run -d -p 5044:5044 -h logstash --name logstash --link elasticsearch:elasticsearch -v "$PWD":/config-dir -v "$PWD/systemd-nspawn":/logs logstash -f /config-dir/logstash.conf
```

For **Docker**:

```bash
    sudo docker run -d -h logstash --name logstash --link elasticsearch:elasticsearch -v "$PWD":/config-dir -v "$PWD/docker":/logs logstash -f /config-dir/logstash.conf
```

Start `Filebeat`:

Before you start Filebeat just make sure that *logstash* has already been running. Then depending on which method you have chosen (Docker or nspawn) run the following commands:

For **systemd-nspawn**:

```bash

    sudo chown root filebeat.yml
    sudo docker run -d -h filebeat --name filebeat --link logstash:logstash -v "$PWD"/filebeat.yml:/filebeat.yml -v "$PWD/systemd-nspawn":/logs prima/filebeat:latest
```

For **Docker**:

```bash

    sudo chown root filebeat.yml
    sudo docker run -d -h filebeat --name filebeat --link logstash:logstash -v "$PWD"/filebeat.yml:/filebeat.yml -v "$PWD/docker":/logs prima/filebeat:latest
```

What's happening behind the scenes is that Filebeat is monitoring the *directory* for files that have `*.log`
as their suffix. As soon it finds one of those, it sends it to `logstash` container at TCP 5044. Then
`logstash` sends these to `elasticsearch` and you can view them using `kibana`.

To monitor the test via `Kibana`, open your browser at `http://localhost:5601` and select:

```bash

    Index name or pattern: filebeat-*
     Time-field name: @timestamp
```

Then you can click at **Discover** and from the **Selected Field** add the tag **source**.
In the search field, you can search for stuff like:

```bash

    "SUCCESS on" AND "scriptlet failed"
    "SUCCESS on" AND "Command exited with status 126"
    "SUCCESS on" AND "no alternatives for"
    "SUCCESS on" AND "wrong permissions"
    "SUCCESS on" AND "cannot verify"
    
    # or also for the failed ones:
    "FAILURE on"
```

## Troubleshooting

In case you don't see any logs there, there might be a good indication that `filebeat` is not sending the
logs to `logstash`. To make sure about it:

```bash
    sudo docker exec logstash ls -l /logs/ | grep '.log'
```

If this command is not returning something, that means that the logs were never sent to logstash. So, the
next step from troubleshooting perspective would be to see if `filebeat` received any logs:

```bash
    sudo docker exec filebeat ls -l /logs | grep '.log'
```

This should let you know if Filebeat is getting the logs
