Instructions
############

First of all you need to `pull` the Tumbleweed docker images.

.. code:: bash

    docker pull opensuse:tumbleweed

Then build your own on top of it, using this Dockerfile:

.. code:: bash

    FROM opensuse:tumbleweed
    MAINTAINER drpaneas <pgeorgiadis@suse.com>

    ENTRYPOINT ["/bin/bash", "-c"]

    # You have to pass the $PKG as an env variable to the the container
    CMD ["zypper -n in -y -l $PKG"]

The build the Docker image:


