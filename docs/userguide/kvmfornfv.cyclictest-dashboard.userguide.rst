.. This work is licensed under a Creative Commons Attribution 4.0 International License.

.. http://creativecommons.org/licenses/by/4.0

========================================
Dashboard for KVM4NFV Daily Test Results
========================================

Abstract
========

This chapter explains the procedure to configure the InfluxDB and Grafana on Node1 or Node2
depending on the testtype to publish KVM4NFV cyclic test results. The cyclictest cases are executed
and results are published on Yardstick Dashboard(Graphana).  InfluxDB is the database which will
store the cyclictest results and Grafana is a visualisation suite to view the maximum,minumum and
average values of the timeseries data of cyclictest results.The framework is shown in below image.

.. Figure:: ../images/dashboard-architecture.png


Version Features
================

+-----------------------------+--------------------------------------------+
|                             |                                            |
|      **Release**            |               **Features**                 |
|                             |                                            |
+=============================+============================================+
|                             | - Data published in Json file Format       |
|       Colorado              | - No database support to store the test's  |
|                             |   latency values of cyclictest             |
|                             | - For each run, the previous run's output  |
|                             |   file is replaced with a new file with    |
|                             |   currents latency values.                 |
+-----------------------------+--------------------------------------------+
|                             | - Test results are stored in Influxdb      |
|                             | - Graphical representation of the latency  |
|       Danube                |   values using Grafana suite. (Dashboard)  |
|                             | - Supports Graphical view for multiple     |
|                             |   testcases and test-types (Stress/Idle)   |
+-----------------------------+--------------------------------------------+


Installation Steps:
===================
To configure Yardstick, InfluxDB and Grafana for KVMFORNFV project following sequence of steps are followed:

**Note:**

All the below steps are done as per the script, which is a part of CICD integration.

.. code:: bash

   For Yardstick:
   git clone https://gerrit.opnfv.org/gerrit/yardstick

   For InfluxDB:
   docker pull tutum/influxdb
   docker run -d --name influxdb -p 8083:8083 -p 8086:8086 --expose 8090 --expose 8099 tutum/influxdb
   docker exec -it influxdb bash
   $influx
   >CREATE USER root WITH PASSWORD 'root' WITH ALL PRIVILEGES
   >CREATE DATABASE yardstick;
   >use yardstick;
   >show MEASUREMENTS;

   For Grafana:
   docker pull grafana/grafana
   docker run -d --name grafana -p 3000:3000 grafana/grafana

The Yardstick document for Grafana and InfluxDB configuration can be found `here`_.

.. _here: https://wiki.opnfv.org/display/yardstick/How+to+deploy+InfluxDB+and+Grafana+locally

Configuring the Dispatcher Type:
================================
Need to configure the dispatcher type in /etc/yardstick/yardstick.conf depending on the dispatcher
methods which are used to store the cyclictest results. A sample yardstick.conf can be found at
/yardstick/etc/yardstick.conf.sample, which can be copied to /etc/yardstick.

.. code:: bash

    mkdir -p /etc/yardstick/
    cp /yardstick/etc/yardstick.conf.sample /etc/yardstick/yardstick.conf

**Dispatcher Modules:**

Three type of dispatcher methods are available to store the cyclictest results.

- File
- InfluxDB
- HTTP

**1. File**:  Default Dispatcher module is file.If the dispatcher module is configured as a file,then the test results are stored in yardstick.out  file.
( default path: /tmp/yardstick.out).
Dispatcher module of "Verify Job" is "Default".So,the results are stored in Yardstick.out file for verify job. Storing all the verify jobs in InfluxDB database causes redundancy of latency values. Hence, a File output format is prefered.

.. code:: bash

    [DEFAULT]
    debug = False
    dispatcher = file

**2. Influxdb**: If the dispatcher module is configured as influxdb, then the test results are stored in Influxdb.Users can check test results stored in the Influxdb(Database) on Grafana which is used to visualize the time series data.

To configure the influxdb ,the following content in /etc/yardstick/yardstick.conf need to updated

.. code:: bash

    [DEFAULT]
    debug = False
    dispatcher = influxdb

Dispatcher module of "Daily Job" is Influxdb.So the results are stored in influxdb and then published to Dashboard.

**3. HTTP**: If the dispatcher module is configured as http, users can check test result on OPNFV testing dashboard which uses MongoDB as backend.

.. code:: bash

    [DEFAULT]
    debug = False
    dispatcher = http

.. Figure:: ../images/UseCaseDashboard.png


Detailing the dispatcher module in verify and daily Jobs:
---------------------------------------------------------

KVM4NFV updates the dispatcher module in the yardstick configuration file(/etc/yardstick/yardstick.conf) depending on the Job type(Verify/Daily).Once the test is completed, results are published to the respective dispatcher modules.

Dispatcher module is configured for each Job type as mentioned below.

1. ``Verify Job`` : Default "DISPATCHER_TYPE" i.e. file(/tmp/yardstick.out) is used. User can also see the test results on Jenkins console log.

.. code:: bash

     *"max": "00030", "avg": "00006", "min": "00006"*

2. ``Daily Job`` : Opnfv Influxdb url is configured as dispatcher module.

.. code:: bash

     DISPATCHER_TYPE=influxdb
     DISPATCHER_INFLUXDB_TARGET="http://104.197.68.199:8086"

Influxdb only supports line protocol, and the json protocol is deprecated.

For example, the raw_result of cyclictest in json format is:
   ::

    "benchmark": {
         "timestamp": 1478234859.065317,
         "errors": "",
         "data": {
            "max": "00012",
            "avg": "00008",
            "min": "00007"
         },
       "sequence": 1
       },
      "runner_id": 23
    }


With the help of "influxdb_line_protocol", the json is transformed as a line string:
   ::

     'kvmfornfv_cyclictest_idle_idle,deploy_scenario=unknown,host=kvm.LF,
     installer=unknown,pod_name=unknown,runner_id=23,scenarios=Cyclictest,
     task_id=e7be7516-9eae-406e-84b6-e931866fa793,version=unknown
     avg="00008",max="00012",min="00007" 1478234859065316864'



Influxdb api which is already implemented in `Influxdb`_ will post the data in line format into the database.

``Displaying Results on Grafana dashboard:``

- Once the test results are stored in Influxdb, dashboard configuration file(Json) which used to display the cyclictest results on Grafana need to be created by following the `Grafana-procedure`_ and then pushed into `yardstick-repo`_

- Grafana can be accessed at `Login`_ using credentials opnfv/opnfv and used for visualizing the collected test data as shown in `Visual`_\


.. Figure:: ../images/Dashboard-screenshot-1.png

.. Figure:: ../images/Dashboard-screenshot-2.png

.. _Influxdb: https://git.opnfv.org/cgit/yardstick/tree/yardstick/dispatcher/influxdb.py

.. _Visual: http://testresults.opnfv.org/grafana/dashboard/db/kvmfornfv-cyclictest

.. _Login: http://testresults.opnfv.org/grafana/login

.. _Grafana-procedure: https://wiki.opnfv.org/display/yardstick/How+to+work+with+grafana+dashboard

.. _yardstick-repo: https://git.opnfv.org/cgit/yardstick/tree/dashboard/KVMFORNFV-Cyclictest

.. _GrafanaDoc: http://docs.grafana.org/

Understanding Kvmfornfv Grafana Dashboard
=========================================

The Kvmfornfv Dashboard found at http://testresults.opnfv.org/ currently supports graphical view of Cyclictest. For viewing Kvmfornfv Dashboard use,

.. code:: bash

    http://testresults.opnfv.org/grafana/dashboard/db/kvmfornfv-cyclictest

    The login details are:

        Username: opnfv
        Password: opnfv

The Dashboard has four tables, each representing a specific test-type of cyclictest case,

- Kvmfornfv_Cyclictest_Idle-Idle
- Kvmfornfv_Cyclictest_CPUstress-Idle
- Kvmfornfv_Cyclictest_Memorystress-Idle
- Kvmfornfv_Cyclictest_IOstress-Idle

Note:

- For all graphs, X-axis is marked with time stamps, Y-axis with value in microsecond units.

**A brief about what each graph of the dashboard represents:**

1. Idle-Idle Graph
-------------------
`Idle-Idle`_ graph displays the Average,Maximum and Minimum latency values obtained by running Idle_Idle test-type of the Cyclictest. Idle_Idle implies that no stress is applied on the Host or the Guest.

.. _Idle-Idle: http://testresults.opnfv.org/grafana/dashboard/db/kvmfornfv-cyclictest?panelId=10&fullscreen

.. Figure:: ../images/Idle-Idle.png

2. CPU_Stress-Idle Graph
--------------------------
`Cpu_Stress-Idle`_ graph displays the Average,Maximum and Minimum latency values obtained by running Idle_Idle test-type of the Cyclictest. Idle_Idle implies that CPU stress is applied on the Host and no stress on the Guest.

.. _Cpu_stress-Idle: http://testresults.opnfv.org/grafana/dashboard/db/kvmfornfv-cyclictest?panelId=11&fullscreen

.. Figure:: ../images/Cpustress-Idle.png

3. Memory_Stress-Idle Graph
----------------------------
`Memory_Stress-Idle`_ graph displays the Average,Maximum and Minimum latency values obtained by running Idle_Idle test-type of the Cyclictest. Idle_Idle implies that Memory stress is applied on the Host and no stress on the Guest.

.. _Memory_Stress-Idle: http://testresults.opnfv.org/grafana/dashboard/db/kvmfornfv-cyclictest?panelId=12&fullscreen

.. Figure:: ../images/Memorystress-Idle.png

4. IO_Stress-Idle Graph
------------------------
`IO_Stress-Idle`_ graph displays the Average,Maximum and Minimum latency values obtained by running Idle_Idle test-type of the Cyclictest. Idle_Idle implies that IO stress is applied on the Host and no stress on the Guest.

.. _IO_Stress-Idle: http://testresults.opnfv.org/grafana/dashboard/db/kvmfornfv-cyclictest?panelId=13&fullscreen

.. Figure:: ../images/IOstress-Idle.png
