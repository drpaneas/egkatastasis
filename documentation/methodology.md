# Methodology

So, at the core of what I'm doing I need to test a package, and I need some sort of test system
to do that. My test system should ensure a couple of things:

* Tests shouldn't influence each other:
  if `pkg A` is incompatible with `pkg B`, we shouldn't notice that
  but both should be able to be installed and tested separately.

* Tests should be ephemeral:
  if a container is finished its job, I want it to be automatically
  removed (deleted) from my machine.
  
* Tests should not affect the host OS that they are running.

In order to do that, I could manually sit down and install them one-by-one, and taking care
of all the changes and the files, by hand. But, personally I wouldn't trust myself to do that
because at some point I would be tired and miss something, not to mention that I would have
taken me a decade and it's also boring a hell. So, I would like to use some isolation, some
sort of technology in which to build my test system.
