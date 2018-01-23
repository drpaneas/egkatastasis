# Motivation

Every once in a while, [openSUSE container images] are
getting build at the [Open Build Service] and later on
they are getting *pushed* at [DockerHub], so users can
*pull* them directly from there. However, [openQA], which is
SUSE's primary tool for testing automation and heavily
integrated with OBS, does _not_ support any containerized
backend for testing at the moment (see [poo#30074](https://progress.opensuse.org/issues/30074)).

> If you are interested to help openQA, please considering
applying for the [GSoC Project](https://github.com/openSUSE/mentoring/issues/92).

As a result, the openSUSE container images are getting
released only with some manual testing from the maintainers
and not by an automated tool. Due to the lack of automation
there were times were the images had [orphaned packages]
and [wrong repositories].

##### This project tries to answer

* How many packages might be problematic without my knowledge?
* How do we know unless we test all of them?
* How many packages are supported? Can we test **all the packages**?
* How big untertaking is this?


Right now, Tumbleweed offers **~25.000 packages** for *64-bit* architecture.
This is a *big* problem, and it's only going to get bigger.
To see if the package installation works on x86_64 platform,
Egkatastasis is trying to test the whole ecosystem.

So, questions started popping-up:

* How much time is it gonna take?
* How much of resources are going to be needed?
* How difficult is it?
* How accurate the results are going to be?

How Egkatastasis is going to do this?

* By running bots under the hood
* Install single package by single package
* Looking on how this can be done quickly. 
* process the results and visualize them

In worst case, we have a system that finds bugs
which we can utilize to improve [Kubic].

[openSUSE container images]: https://github.com/openSUSE/docker-containers
[DockerHub]: https://hub.docker.com/_/opensuse/
[openQA]: http://open.qa/
[orphaned packages]: https://github.com/openSUSE/docker-containers/issues/54
[wrong repositories]: https://github.com/openSUSE/docker-containers/issues/64
[Open Build Service]: https://build.opensuse.org/project/subprojects/Virtualization:containers:images
[Kubic]: https://github.com/kubic-project
