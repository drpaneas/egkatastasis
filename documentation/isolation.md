Isolation Technologies
======================

	1. Virtual Machines
		Give us great isolation, terrible overhead and they are not so easy to interact with
		scripting. I mean you can do it, but it's not super fan.

	2. Chroots
		A short of completely the opposite result. Pretty terrible isolation, cause they just
		isolate the filesystem but on the other hand they are incredibly low-overhead and it's
		relatively easy to get information out of them because they are processes, but dealing
		with spinning up with and isolated environment and breaking it down again, it's a little
		bit more complicated and the tooling is not so great.

	3. Containers
		A short of mid point. They offer decent isolation, they offer reasonably good overhead
		and give you some trade-off in this area as well. But what I think is the really winning
		thing for container is that if you have got an abstraction like docker sitting on top of
		your containers then it's really easy to interact with them. And this is both in terms of
		spinning them up and spinning them down and getting information in and out. Docker's
		scriptibility it's hands-down the thing that made it a winner for my case. I'm a lazy guy
		and I want to use a tool that "just works" with the "minimum effort" from myside. And also
		if it works for Google and Amazon, it pretty much should work for me.

Let me show you what I mean by that. Let's run a docker container. So let's run interactively
and even with an attached terminal, cleaning up afterwards, passing an environment variable
FOO with the value BAR, based on opensuse.

	docker run -i -t --rm --env FOO=bar opensuse:42.2

Did you noticed the change in the prompt? Docker found for me behind the scenes the base image
of opensuse 42.2 and I'm already sitting now inside this container.

	ls

So, I am in a completely isolated filesystem and I can do whatever I want here without affecting
the host.

	echo $FOO

I can very easily access the contents of an enviroment variable that I passed from the host OS
to my container.

	exit 42

And if I exit with some meaningful exit status

	echo $?

That exit status is preserved outside the container.

So, my hope is that is pretty easy to imagine how you would go from that ability to
bring up a container, having it automatically cleaned up, get information in, get information out,
into a test system. So, that's what I did.

Let's build a container to test a package
=========================================

I am trying to assume no background in docker here, so I am gonna talk you to through the process
and I am also gonna highlight that is really simple. It's so simple in fact to build this test
system that ... I would put all the code on the screen :D

This is the Dockerfile, so this is the instructions on how to build an image for Docker
in which your container will be based upon. So, I have one image, for reasons I want
my testing environment to be the same (consistent), but I will spawn containers from
this image, meaning multiple testing environments which all will be identically the same.
This is analogous to VM snapshots, were I have a snapshot and I can bring up many VMs
booting from this snapshot. So this is my dockerfile (minis to lines for my specific proxies)

	FROM ppc64le/ubuntu:16.04

The Dockerfile is written in its own language and it's pretty much straightforward. This line
says, go and pick up the official ubuntu docker image for ppc64le which IBM made available
on the internet. Take this as a base, and start building on top of that.

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y build-essential curl libcurl4-openssl-dev \
					   libxml2-dev libpq-dev libmysqlclient-dev \
					   libprcre3-dev libxslt-dev libmagickcore-dev \
					   libpango1.0-dev default-jdk git cmake \
					   libmagic-dev libatk1.0-dev libgsl10-dev \
					   libgl1-mesa-dev libfreeimage-dev \
					   libopenal-dev libsndfile-dev libgtk2-dev \
					   libgirepository1.0-dev libsasl2-dev \
					   libtag1-dev libavahi-compat-libdnsssd-dev \
					   libmemcached-ev uuid-dev libsdl12-dev

Then I install a bunch of packages just because a bunch of ruby gems are trying to interact
with C libraries and these are one of the most popular C libraries that people use. So, I 
installed the `dev` files.

RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -- && \
	curl -sSL https://get.rvm.io | bash -s stable --ruby=2.2.6 && \
	rm -rf /var/cache/apt/* /usr/local/rvm/src && \
	useradd -m -G rvm tester

Next thing I do is the terrible sin of packing shell scripts to bash which is installing `rvm`.
RVM is the technology for isolating Ruby versions, allowing people to install Ruby packages
without having to be necessarrily a sysadmin. So, I am installing Ruby 2.2.6 and then I am creating
an unpriviledged user called 'tester' and I am giving him the ability to administer Ruby packages
by making him member of RVM group. So, I don't strictly need RVM but it allows me to install packages without being root.

USER tester

So next we are dropping root priviledges and we become the user 'tester' in our docker container.
So everything before this is running as root, and everything after this is running as unpriviledged
user inside the container.

RUN bash -c "source /usr/local/rvm/scripts/rvm && \
			 gem install --no-rdoc --no-ri nokogiri"

Next, this installs the `nokogiri` gem because a billion things depend on it, so it will be
cached, and get out of the way early.

COPY gemrc /home/tester/.gemrc
ENV http_proxy=http://localhost:3128/ \
	https_proxy=http://localhost:3128/

These two lines push everything through a local HTTP proxy. Why not HTTPS? Isn't it secure?
I will explain later whythis is a good idea. Just trust me on this for now.

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["source /usr/local/rvm/scripts/rvm && \
	  gem install --no-rdoc --no-ri $GEM"]

And this is the final part of the docker file. This says that when we run a container based
on this image that we are building, the command that I want you to run in the container is
"bash with loading rvm and installing the gem given by the env variable $GEM". This is all you need to test a gem. So, let's do that.

This allows us to test a gem, and this will give us a SUCCESS or FAILURE and a logfile.
What this doesn't do for us, which is kind of important, is to give us any ability
to enforce a timeout and this is a bit unfortunate, mostly because we don't want this to
take forever. We want this to run quickly and do other things with our lives.

So let's build our image

	docker -t rubytest .

Now let's run this container:

docker run -it --rm --net=host --tmpfs=/usr/local/rvm/gems/ruby-2.2.6/gems:rw,mode=777.gid=1000.exec --env GEM=rails rubytest bash

-it --> run it interactively in my tty
--rm --> clean it up afterwards

If I echo the status: echo $?
I can see that 0 which is a success. Hooray! So, no we can test any package by
changing the enviroment option.
