# Egkatastasis

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/1580/badge)](https://bestpractices.coreinfrastructure.org/projects/1580)


<img src="https://github.com/drpaneas/egkatastasis/blob/master/images/egkatastasis_logo.png" width="100">

----

Egkatastasis is an open source system for testing [openSUSE container images]
providing basic mechanisms for installation, log analysis, and visualization 
of every package contained into the official repositories.

Egkatastasis tests production container workloads at scale using [Docker]
and [systemd-nspawn], combined with the best-of-breed ideas and practices
from the community.

Egkatastasis is hosted by [GitHub]. If you are interested in openSUSE
and you want to help shape the evolution of testing [openSUSE container images],
consider joining our effort by contributing in any way that feels fun
for you.

----

## To start using Egkatastasis

The [GitHub] repository hosts all the information about building
Egkatastasis in just a few minutes, how to contribute code
and documentation, who to contact about what, etc.

If you want to use Egkatastasis right away, testing a single
package, *without* any logging analysis:

##### You have a working Docker daemon

```bash
$ git clone https://github.com/drpaneas/egkatastasis
$ cd ./docker
$ pkg='vim'
$ ./testit.sh ${pkg}
$ cat ${pkg}.log
```

For the full story, head over to the [documentation].

See our [live demo].

## Governance

Egkatastasis is an independent project created by [Panos Georgiadis](http://panosgeorgiadis.com/) which will hopefully being built and shaped by a growing community of contributors at some point in time.




[openSUSE container images]: https://hub.docker.com/_/opensuse/
[Docker]: https://www.docker.com/
[systemd-nspawn]: https://www.freedesktop.org/software/systemd/man/systemd-nspawn.html
[GitHub]: https://github.com/drpaneas/egkatastasis
[documentation]: https://github.com/drpaneas/egkatastasis/blob/master/documentation/README.md
[live demo]: https://youtube.com
