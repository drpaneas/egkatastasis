
*Note: systemd >= 232 version is a hard requirement!*



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

First of all clone the project:

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
granted the fact that the logs are stored locally in either `./egkatastasis/docker/` for *Docker*
or in `./egkatastasis/systemd-nspawn/` directory for *systemd-nspawn*.

Start Logstash:

Depending on which method you have chosen (Docker or SystemD) run the following commands:

For **systemd-nspawn**:

.. code:: bash

    sudo docker run -d -p 5044:5044 -h logstash --name logstash --link elasticsearch:elasticsearch -v "$PWD":/config-dir -v "$PWD/systemd-nspawn":/logs logstash -f /config-dir/logstash.conf
    
For **Docker**:

.. code:: bash

    sudo docker run -d -h logstash --name logstash --link elasticsearch:elasticsearch -v "$PWD":/config-dir -v "$PWD/docker":/logs logstash -f /config-dir/logstash.conf

Start `Filebeat`:

Before you start Filebeat just make sure that *logstash* has already been running. Then depending on which method you have chosen (Docker or nspawn) run the following commands:

For **systemd-nspawn**:

.. code:: bash

    sudo chown root filebeat.yml
    sudo docker run -d -h filebeat --name filebeat --link logstash:logstash -v "$PWD"/filebeat.yml:/filebeat.yml -v "$PWD/systemd-nspawn":/logs prima/filebeat:latest

For **Docker**:

.. code:: bash

    sudo chown root filebeat.yml
    sudo docker run -d -h filebeat --name filebeat --link logstash:logstash -v "$PWD"/filebeat.yml:/filebeat.yml -v "$PWD/docker":/logs prima/filebeat:latest

What's happening behind the scenes is that Filebeat is monitoring the *directory* for files that have `*.log`
as their suffix. As soon it finds one of those, it sends it to `logstash` container at TCP 5044. Then
`logstash` sends these to `elasticsearch` and you can view them using `kibana`.

To monitor the test via `Kibana`, open your browser at `http://localhost:5601` and select:

.. code:: bash

    Index name or pattern: filebeat-*
     Time-field name: @timestamp

Then you can click at **Discover** and from the **Selected Field** add the tag **source**.
In the search field, you can search for stuff like:

.. code:: bash

    "SUCCESS on" AND "scriptlet failed"
    "SUCCESS on" AND "Command exited with status 126"
    "SUCCESS on" AND "no alternatives for"
    "SUCCESS on" AND "wrong permissions"
    "SUCCESS on" AND "cannot verify"
    
    # or also for the failed ones:
    "FAILURE on"

Troubleshooting
===============

In case you don't see any logs there, there might be a good indication that `filebeat` is not sending the
logs to `logstash`. To make sure about it:

.. code:: bash

    sudo docker exec logstash ls -l /logs/ | grep '.log'
    
If this command is not returning something, that means that the logs were never sent to logstash. So, the
next step from troubleshooting perspective would be to see if `filebeat` received any logs:

.. code:: bash

    sudo docker exec filebeat ls -l /logs | grep '.log'

This should let you know if Filebeat is getting the logs
