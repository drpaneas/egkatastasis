FROM opensuse:tumbleweed
MAINTAINER drpaneas <pgeorgiadis@suse.com>

ENTRYPOINT ["/bin/bash", "-c"]

# You have to pass the $PKG as an env variable to the the container
CMD ["zypper -n in -y -l $PKG"]
