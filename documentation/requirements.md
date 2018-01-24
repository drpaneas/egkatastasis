# Requirements for the test environment


	1. Isolation (don't destroy my machine)
		I would like to give me good isolation because I would like something to protect
		my machine from my code

	2. Low Overhead (scalable)
		I would like it to be low overhead. So for 25.000 packages, if it takes 1 minute a minute
		of CPU time to bring up and down this isolated environment that is 17,36 days of CPU time
    		just for the preparation of the environment!
		Gosh, that's TOO much of CPU time, even accross 20 Cores, is still too much.

	3. Easy to script (n00b's friendly)
		Lastly, I would like it to be easy to script. There are 2 things under that umbrella:
		I need to be able to bring-up and tear-down this isolated environment in a scripted
		way. And I also to get information in and get information out, again in a scripted way.
		I would like to get in the package name I want to test, and get out SUCCESS or FAILURE
		and of course the logfile.
