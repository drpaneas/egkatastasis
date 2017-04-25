Instructions
############

First of all you need to `pull` the Tumbleweed docker images.

.. code:: bash

    docker pull opensuse:tumbleweed

Then you need to create a file called `packages.txt` which will consist of the
packages you would like to test. This file can be automatically generated using
the `fetch_pkglist.sh` script.

.. code:: bash

    ./fetch_pkglist.sh

As soon as the `packages.txt` has been populated, then you can start your test
by running the `test_all_parallel.sh` script.

.. code:: bash

    ./test_all_parallel.sh

If you like to test packages against specific architectures (by default all
architectures are tests) you can provide the architecture type as argument:

.. code:: bash

    ./test_all_parallel.sh x86_64

* Supported arguments are: `x86_64`, `i586`, `i686`, `noarch`.

In case you would like to monitor the current status while the test is running,
then you can use the `monitor.sh` script.

.. code:: bash

    ./monitor.sh

In case you are testing against a specific architecture, then you must specify
this also here as an argument:

.. code:: bash

    ./monitor.sh x86_64

* Supported arguments are: `x86_64`, `i586`, `i686`, `noarch`.

Last but not least, some kind of parsing can be achieved via `parser.sh`.

.. code:: bash

    ./parser.sh


Rerun
#####

Delete the `.log` and `list.` files

.. code:: bash

    rm *.list
    rm *.log
