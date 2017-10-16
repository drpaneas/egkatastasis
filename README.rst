egkatastasis
############

openSUSE Tumbleweed next-gen installation testing

Utilizing the power and the speed of containers, the system spawns as many containers as many packages are existing
in Tumbleweed and tries to install them. The testing scenario is that each package should be able to be installed
in a clean Tumbleweed system.

.. image:: images/image_1.jpg

So far, there are two implementations:

* systemd-nspawn
* docker

Feel free to try both of them.

The target goal is to catch installation problems for the already released packages
(if there are any) such as dependency conflicts and ugly RPM additional outputs.

In the process of building this, my personal goal is to learn about containers
and their possibilities.

Docker
######

Look for the `README` into the `Docker` folder.


systemd-nspawn
##############

Look for the `README` into the `systemd-nspawn` folder.


ELK Stack
#########

First all clone the project:

.. code:: bash

    git clone https://github.com/drpaneas/egkatastasis

Then change directory into `egkatastasis` root folder:

.. code:: bash

    cd egkatastasis/
   

Start ElasticSearch:

.. code:: bash

    sudo docker run -d -p 9200:9200 -p 9300:9300 -it -h elasticsearch --name elasticsearch elasticsearch

Start Kibana:

.. code:: bash

    sudo docker run -d -p 5601:5601 -h kibana --name kibana --link elasticsearch:elasticsearch kibana

Then start testing and generate some logs using either the Docker or the
systemd-nspawn container. As soon as you have initiated the testing process
you can now start `logstash`. In the following examples, we are taking as
granted the fact that the logs are stored locally in either `./egkatastasis/docker/logs/`
or in `./egkatastasis/systemd-nspawn/logs/` directory.

Logstash:

.. code:: bash

    sudo docker run -h logstash --name logstash --link elasticsearch:elasticsearch -it --rm -v "$PWD":/config-dir -v "$PWD/docker":/logs logstash -f /config-dir/logstash.conf

Once the logstash has been started, it's time to fire up `Filebeat`:

For **Docker**:

.. code:: bash

    sudo chown root filebeat.yml
    sudo docker run -h filebeat --name filebeat --link logstash:logstash -it --rm -v "$PWD"/filebeat.yml:/filebeat.yml -v "$PWD/docker":/logs prima/filebeat:latest

For **systemd-nspawn**:

.. code:: bash

    sudo chown root filebeat.yml
    sudo docker run -h filebeat --name filebeat --link logstash:logstash -it --rm -v "$PWD"/filebeat.yml:/filebeat.yml -v "$PWD/systemd-nspawn":/logs prima/filebeat:latest


To monitor the test via `Kibana`, open your browser at `http://localhost:5601` and select:

.. code:: bash

    Index name or pattern: filebeat-*
     Time-field name: @timestamp
     
