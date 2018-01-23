# Isolation Technologies

* Virtual Machines

		Give us great isolation, terrible overhead and they are not so easy to interact with
		scripting. I mean you can do it, but it's not super fan.

* Chroots

		A short of completely the opposite result. Pretty terrible isolation. Because they just
		isolate the filesystem but on the other hand they are incredibly low-overhead and it's
		relatively easy to get information out of them because they are processes, but dealing
		with spinning up with and isolated environment and breaking it down again, it's a little
		bit more complicated and the tooling is not so great.

* Containers

		A short of mid point. They offer decent isolation, they offer reasonably good overhead
		and give you some trade-off in this area as well. But what I think is the really winning
		thing for container is that if you have got an abstraction like docker sitting on top of
		your containers then it's really easy to interact with them. And this is both in terms of
		spinning them up and spinning them down and getting information in and out. Docker's
		scriptibility it's hands-down the thing that made it a winner for my case. I'm a lazy guy
		and I want to use a tool that "just works" with the "minimum effort" from myside. And also
		if it works for Google and Amazon, it pretty much should work for me.
