.. This work is licensed under a Creative Commons Attribution 4.0 International License.

.. http://creativecommons.org/licenses/by/4.0

.. _scenario-guide:

============================
KVM4NFV Scenario-Description
============================

Abstract
--------

This document describes the procedure to deploy/test KVM4NFV scenarios in a nested virtualization
environment. This has been verified with os-nosdn-kvm-ha, os-nosdn-kvm-noha,os-nosdn-kvm_ovs_dpdk-ha,
os-nosdn-kvm_ovs_dpdk-noha and os-nosdn-kvm_ovs_dpdk_bar-ha test scenarios.

Version Features
----------------

+-----------------------------+---------------------------------------------+
|                             |                                             |
|      **Release**            |               **Features**                  |
|                             |                                             |
+=============================+=============================================+
|                             | - Scenario Testing feature was not part of  |
|       Colorado              |   the Colorado release of KVM4NFV           |
|                             |                                             |
+-----------------------------+---------------------------------------------+
|                             | - High Availability/No-High Availability    |
|                             |   deployment configuration of KVM4NFV       |
|                             |   software suite using Fuel                 |
|                             | - Multi-node setup with 3 controller and    |
|                             |   2 compute nodes are deployed for HA       |
|       Danube                | - Multi-node setup with 1 controller and    |
|                             |   3 compute nodes are deployed for NO-HA    |
|                             | - Scenarios os-nosdn-kvm_ovs_dpdk-ha,       |
|                             |   os-nosdn-kvm_ovs_dpdk_bar-ha,             |
|                             |   os-nosdn-kvm_ovs_dpdk-noha,               |
|                             |   os-nosdn-kvm_ovs_dpdk_bar-noha            |
|                             |   are supported                             |
+-----------------------------+---------------------------------------------+
|                             | - High Availability/No-High Availability    |
|                             |   deployment configuration of KVM4NFV       |
|                             |   software suite using Apex                 |
|                             | - Multi-node setup with 3 controller and    |
|       Euphrates             |   2 compute nodes are deployed for HA       |
|                             | - Multi-node setup with 1 controller and    |
|                             |   1 compute node are deployed for NO-HA     |
|                             | - Scenarios os-nosdn-kvm_ovs_dpdk-ha,       |
|                             |   os-nosdn-kvm_ovs_dpdk-noha,               |
|                             |   are supported                             |
+-----------------------------+---------------------------------------------+



Introduction
------------
The purpose of os-nosdn-kvm_ovs_dpdk-ha,os-nosdn-kvm_ovs_dpdk_bar-ha and
os-nosdn-kvm_ovs_dpdk-noha,os-nosdn-kvm_ovs_dpdk_bar-noha scenarios testing is to
test the High Availability/No-High Availability deployment and configuration of
OPNFV software suite with OpenStack and without SDN software.

This OPNFV software suite includes OPNFV KVM4NFV latest software packages
for Linux Kernel and QEMU patches for achieving low latency and also OPNFV Barometer for traffic,
performance and platform monitoring.

When using Fuel installer, High Availability feature is achieved by deploying OpenStack
multi-node setup with 1 Fuel-Master,3 controllers and 2 computes nodes. No-High Availability
feature is achieved by deploying OpenStack multi-node setup with 1 Fuel-Master,1 controllers
and 3 computes nodes.

When using Apex installer, High Availability feature is achieved by deploying Openstack
multi-node setup with 1 undercloud, 3 overcloud controllers and 2 overcloud compute nodes.
No-High Availability feature is achieved by deploying Openstack multi-node setup with
1 undercloud, 1 overcloud controller and 1 overcloud compute nodes.

KVM4NFV packages will be installed on compute nodes as part of deployment.
The scenario testcase deploys a multi-node setup by using OPNFV Fuel and Apex deployer.

System pre-requisites
---------------------

- RAM - Minimum 16GB
- HARD DISK - Minimum 500GB
- Linux OS installed and running
- Nested Virtualization enabled, which can be checked by,

.. code:: bash

        $ cat /sys/module/kvm_intel/parameters/nested
          Y

        $ cat /proc/cpuinfo | grep vmx

*Note:*
If Nested virtualization is disabled, enable it by,

.. code:: bash

     For Ubuntu:
     $ modeprobe kvm_intel
     $ echo Y > /sys/module/kvm_intel/parameters/nested
     $ sudo reboot

     For RHEL:
     $ cat << EOF > /etc/modprobe.d/kvm_intel.conf
       options kvm-intel nested=1
       options kvm-intel enable_shadow_vmcs=1
       options kvm-intel enable_apicv=1
       options kvm-intel ept=1
       EOF
     $ cat << EOF > /etc/sysctl.d/98-rp-filter.conf
       net.ipv4.conf.default.rp_filter = 0
       net.ipv4.conf.all.rp_filter = 0
       EOF
     $ sudo reboot

Environment Setup
-----------------

**Enable network access after the installation**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For **CentOS**.,
Login as "root" user. After the installation complete, the Ethernet interfaces are not enabled by the
default in Centos 7, you need to change the line "ONBOOT=no" to "ONBOOT=yes" in the network interface
configuration file (such as ifcfg-enp6s0f0 or ifcfg-em1 … whichever you want to connect) in
/etc/sysconfig/network-scripts sub-directory. The default BOOTPROTO is dhcp in the network interface
configuration file. Then use following command to enable the network access:

.. code:: bash

   systemctl restart network

**Configuring Proxy**
~~~~~~~~~~~~~~~~~~~~~

For **Ubuntu**.,
Create an apt.conf file in /etc/apt if it doesn't exist. Used to set proxy for apt-get if working behind a proxy server.

.. code:: bash

   Acquire::http::proxy "http://<username>:<password>@<proxy>:<port>/";
   Acquire::https::proxy "https://<username>:<password>@<proxy>:<port>/";
   Acquire::ftp::proxy "ftp://<username>:<password>@<proxy>:<port>/";
   Acquire::socks::proxy "socks://<username>:<password>@<proxy>:<port>/";

For **CentOS**.,
Edit /etc/yum.conf to work behind a proxy server by adding the below line.

.. code:: bash

   $ echo "proxy=http://<username>:<password>@<proxy>:<port>/" >> /etc/yum.conf

**Install redsocks**
~~~~~~~~~~~~~~~~~~~~

For **CentOS**.,
Since there is no redsocks package for CentOS Linux release 7.2.1511, you need build redsocks from source yourself. Using following commands to create  “proxy_redsocks” sub-directory at /root:

.. code:: bash

   cd ~
   mkdir proxy_redsocks

Since you can’t download file at your Centos system yet. At other Centos or Ubuntu system, use following command to download redsocks source for Centos into a file “redsocks-src”;

.. code:: bash

   wget -O redsocks-src --no-check-certificate https://github.com/darkk/redsocks/zipball/master

Also download libevent-devel-2.0.21-4.el7.x86_64.rpm by:

.. code:: bash

   wget ftp://fr2.rpmfind.net/linux/centos/7.2.1511/os/x86_64/Packages/libevent-devel-2.0.21-4.el7.x86_64.rpm

Copy both redsock-src and libevent-devel-2.0.21-4.el7.x86_64.rpm files into ~/proxy_redsocks in your Centos system by “scp”.

Back to your Centos system, first install libevent-devel using libevent-devel-2.0.21-4.el7.x86_64.rpm by:

.. code:: bash

   cd ~/proxy_redsocks
   yum install –y libevent-devel-2.0.21-4.el7.x86_64.rpm

Build redsocks by:

.. code:: bash

   cd ~/proxy_redsocks
   unzip redsocks-src
   cd darkk-redsocks-78a73fc
   yum –y install gcc
   make
   cp redsocks ~/proxy_redsocks/.

Create a redsocks.conf in ~/proxy_redsocks with following contents:

.. code:: bash

   base {
   log_debug = on;
   log_info = on;
   log = "file:/root/proxy.log";
   daemon = on;
   redirector = iptables;
   }
   redsocks {
   local_ip = 0.0.0.0;
   local_port = 6666;
   // socks5 proxy server
   ip = <proxy>;
   port = 1080;
   type = socks5;
   }
   redudp {
   local_ip = 0.0.0.0;
   local_port = 8888;
   ip = <proxy>;
   port = 1080;
   }
   dnstc {
   local_ip = 127.0.0.1;
   local_port = 5300;
   }

Start redsocks service by:

.. code:: bash

   cd ~/proxy_redsocks
   ./redsocks –c redsocks.conf

*Note*
The redsocks service is not persistent and you need to execute the above-mentioned commands after every reboot.

Create intc-proxy.sh in ~/proxy_redsocks with following contents and make it executable by “chmod +x intc-proxy.sh”:

.. code:: bash

   iptables -t nat -N REDSOCKS
   iptables -t nat -A REDSOCKS -d 0.0.0.0/8 -j RETURN
   iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN
   iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
   iptables -t nat -A REDSOCKS -d 169.254.0.0/16 -j RETURN
   iptables -t nat -A REDSOCKS -d 172.16.0.0/12 -j RETURN
   iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN
   iptables -t nat -A REDSOCKS -d 224.0.0.0/4 -j RETURN
   iptables -t nat -A REDSOCKS -d 240.0.0.0/4 -j RETURN
   iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 6666
   iptables -t nat -A REDSOCKS -p udp -j REDIRECT --to-ports 8888
   iptables -t nat -A OUTPUT -p tcp  -j REDSOCKS
   iptables -t nat -A PREROUTING  -p tcp  -j REDSOCKS

Enable the REDSOCKS nat chain rule by:

.. code:: bash

   cd ~/proxy_redsocks
   ./intc-proxy.sh

*Note*
These REDSOCKS nat chain rules are not persistent and you need to execute the above-mentioned commands after every reboot.

**Network Time Protocol (NTP) setup and configuration**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Install ntp by:

.. code:: bash

    $ sudo apt-get update
    $ sudo apt-get install -y ntp

Insert the following two lines after  “server ntp.ubuntu.com” line and before “ # Access control configuration; see `link`_ for” line in /etc/ntp.conf file:

.. _link: /usr/share/doc/ntp-doc/html/accopt.html

.. code:: bash

   server 127.127.1.0
   fudge 127.127.1.0 stratum 10

Restart the ntp server to apply the changes

.. code:: bash

    $ sudo service ntp restart

Scenario Testing
----------------

There are three ways of performing scenario testing,
    - 1 Fuel
    - 2 Apex
    - 3 OPNFV-Playground
    - 4 Jenkins Project

Fuel
~~~~

**1 Clone the fuel repo :**

.. code:: bash

   $ git clone https://gerrit.opnfv.org/gerrit/fuel.git

**2 Checkout to the specific version of the branch to deploy by:**

The default branch is master, to use a stable release-version use the below.,

.. code:: bash
    To check the current branch
    $ git branch

    To check out a specific branch
    $ git checkout stable/Colorado

**3  Building the Fuel iso :**

.. code:: bash

              $ cd ~/fuel/ci/
              $ ./build.sh -h

Provide the necessary options that are required to build an iso.
Create a ``customized iso`` as per the deployment needs.

.. code:: bash

              $ cd ~/fuel/build/
              $ make

(OR) Other way is to download the latest stable fuel iso from `here`_.

.. _here: http://artifacts.opnfv.org/fuel.html

.. code:: bash

   http://artifacts.opnfv.org/fuel.html

**4 Creating a new deployment scenario**

``(i). Naming the scenario file``

Include the new deployment scenario yaml file in ~/fuel/deploy/scenario/. The file name should adhere to the following format:

.. code:: bash

    <ha | no-ha>_<SDN Controller>_<feature-1>_..._<feature-n>.yaml

``(ii). Meta data``

The deployment configuration file should contain configuration metadata as stated below:

.. code:: bash

              deployment-scenario-metadata:
                      title:
                      version:
                      created:

``(iii). “stack-extentions” Module``

To include fuel plugins in the deployment configuration file, use the “stack-extentions” key:

.. code:: bash

             Example:
                     stack-extensions:
                        - module: fuel-plugin-collectd-ceilometer
                          module-config-name: fuel-barometer
                          module-config-version: 1.0.0
                          module-config-override:
                          #module-config overrides

**Note:**
The “module-config-name” and “module-config-version” should be same as the name of plugin configuration file.

The “module-config-override” is used to configure the plugin by overrriding the corresponding keys in
the plugin config yaml file present in ~/fuel/deploy/config/plugins/.

``(iv).  “dea-override-config” Module``

To configure the HA/No-HA mode, network segmentation types and role to node assignments, use the “dea-override-config” key.

.. code:: bash

        Example:
        dea-override-config:
               environment:
                   mode: ha
                   net_segment_type: tun
               nodes:
               - id: 1
                  interfaces: interfaces_1
                  role: mongo,controller,opendaylight
               - id: 2
                 interfaces: interfaces_1
                 role: mongo,controller
               - id: 3
                  interfaces: interfaces_1
                  role: mongo,controller
               - id: 4
                  interfaces: interfaces_1
                  role: ceph-osd,compute
               - id: 5
                  interfaces: interfaces_1
                  role: ceph-osd,compute
        settings:
            editable:
                storage:
                     ephemeral_ceph:
                              description: Configures Nova to store ephemeral volumes in RBD. This works best if Ceph is enabled for volumes and images, too. Enables live migration of all types of Ceph backed VMs (without this option, live migration will only work with VMs launched from Cinder volumes).
                              label: Ceph RBD for ephemeral volumes (Nova)
                              type: checkbox
                              value: true
                              weight: 75
                     images_ceph:
                              description: Configures Glance to use the Ceph RBD backend to store images.If enabled, this option will prevent Swift from installing.
                              label: Ceph RBD for images (Glance)
                              restrictions:
                              - settings:storage.images_vcenter.value == true: Only one Glance backend could be selected.
                              type: checkbox
                              value: true
                              weight: 30

Under the “dea-override-config” should provide atleast {environment:{mode:'value},{net_segment_type:'value'}
and {nodes:1,2,...} and can also enable additional stack features such ceph,heat which overrides
corresponding keys in the dea_base.yaml and dea_pod_override.yaml.

``(v). “dha-override-config”  Module``

In order to configure the pod dha definition, use the “dha-override-config” key.
This is an optional key present at the ending of the scenario file.

``(vi). Mapping to short scenario name``

The scenario.yaml file is used to map the short names of scenario's to the one or more deployment scenario configuration yaml files.
The short scenario names should follow the scheme below:

.. code:: bash

               [os]-[controller]-[feature]-[mode]-[option]

        [os]: mandatory
        possible value: os

Please note that this field is needed in order to select parent jobs to list and do blocking relations between them.

.. code:: bash


    [controller]: mandatory
    example values: nosdn, ocl, odl, onos

    [mode]: mandatory
    possible values: ha, noha

    [option]: optional

Used for the scenarios those do not fit into naming scheme.
Optional field in the short scenario name should not be included if there is no optional scenario.

.. code:: bash

            Example:
                1. os-nosdn-kvm-noha
                2. os-nosdn-kvm_ovs_dpdk_bar-ha


Example of how short scenario names are mapped to configuration yaml files:

.. code:: bash

                  os-nosdn-kvm_ovs_dpdk-ha:
                      configfile: ha_nfv-kvm_nfv-ovs-dpdk_heat_ceilometer_scenario.yaml

Note:

- ( - )  used for separator of fields. [os-nosdn-kvm_ovs_dpdk-ha]

- ( _ ) used to separate the values belong to the same field. [os-nosdn-kvm_ovs_bar-ha].

**5 Deploying the scenario**

Command to deploy the os-nosdn-kvm_ovs_dpdk-ha scenario:

.. code:: bash

        $ cd ~/fuel/ci/
        $ sudo ./deploy.sh -f -b file:///tmp/opnfv-fuel/deploy/config -l devel-pipeline -p default -s ha_nfv-kvm_nfv-ovs-dpdk_heat_ceilometer_scenario.yaml -i file:///tmp/opnfv.iso

where,
    ``-b`` is used to specify the configuration directory

    ``-f`` is used to re-deploy on the existing deployment

    ``-i`` is used to specify the image downloaded from artifacts.

    ``-l`` is used to specify the lab name

    ``-p`` is used to specify POD name

    ``-s`` is used to specify the scenario file

**Note:**

.. code:: bash

           Check $ sudo ./deploy.sh -h for further information.

Apex
~~~~

Apex installer uses CentOS as the platform.

**1 Install Packages :**

Install necessary packages by following:

.. code:: bash

   cd ~
   yum install –y git rpm-build python-setuptools python-setuptools-devel
   yum install –y epel-release gcc
   curl -O https://bootstrap.pypa.io/get-pip.py
   um install –y python3 python34
   /usr/bin/python3.4 get-pip.py
   yum install –y python34-devel python34-setuptools
   yum install –y libffi-devel python-devel openssl-devel
   yum -y install libxslt-devel libxml2-devel

Then you can use “dev_deploy_check.sh“ in Apex installer source to install the remaining necessary packages by following:

.. code:: bash

   cd ~
   git clone https://gerrit.opnfv.org/gerrit/p/apex.git
   export CONFIG=$(pwd)/apex/build
   export LIB=$(pwd)/apex/lib
   export PYTHONPATH=$PYTHONPATH:$(pwd)/apex/lib/python
   cd ci
   ./dev_deploy_check.sh
   yum install –y python2-oslo-config python2-debtcollector


**2 Create ssh key :**

Use following commands to create ssh key, when asked for passphrase, just enter return for empty passphrase:

.. code:: bash

   cd ~
   ssh-keygen -t rsa

Then prepare the authorized_keys for Apex scenario deployment:

.. code:: bash

   cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys

**3 Create default pool :**

Use following command to default pool device:

.. code:: bash

   cd ~
   virsh pool-define /dev/stdin <<EOF
   <pool type='dir'>
     <name>default</name>
     <target>
       <path>/var/lib/libvirt/images</path>
     </target>
   </pool>
   EOF

Use following commands to start and set autostart the default pool device:

.. code:: bash

   virsh pool-start default
   virsh pool-autostart default

Use following commands to verify the success of the creation of the default pool device and starting and setting autostart of the default pool device:

.. code:: bash

   virsh pool-list
   virsh pool-info default

**4 Get Apex source code :**

Get Apex installer source code:

.. code:: bash

   git clone https://gerrit.opnfv.org/gerrit/p/apex.git
   cd apex

**5 Modify code to work behind proxy :**

In “lib” sub-directory of Apex source, change line 284 “if ping -c 2 www.google.com > /dev/null; then” to “if curl www.google.com > /dev/null;
then” in “common-functions.sh” file, since we can’t ping www.google.com behind Intel proxy.

**6 Setup build environment :**

Setup build environment by:

.. code:: bash

   cd ~
   export BASE=$(pwd)/apex/build
   export LIB=$(pwd)/apex/lib
   export PYTHONPATH=$PYTHONPATH:$(pwd)/apex/lib/python
   export IMAGES=$(pwd)/apex/.build

**7 Build Apex installer :**

Build undercloud image by:

.. code:: bash

   cd ~/apex/build
   make images-clean
   make undercloud

You can look at the targets in ~/apex/build/Makefile to build image for specific feature.
Following show how to build vanilla ODL image (this can be used to build the overcloud image for basic (nosdn-nofeature) and opendaylight test scenario:

.. code:: bash

   cd ~/apex/build
   make overcloud-opendaylight

You can build the complete full set of images (undercloud, overcloud-full, overcloud-opendaylight, overcloud-onos) by:

.. code:: bash

   cd ~/apex/build
   make images

**8 Modification of network_settings.yaml :**

Since we are working behind proxy, we need to modify the network_settings.yaml in ~/apex/config/network
to make the deployment work properly. In order to avoid checking our modification into the repo accidentally,
it is recommend that you copy “network_settings.yaml” to “intc_network_settings.yaml” in the ~/apex/config/network and do following modification in intc_network_settings.yaml:

Change dns_nameservers settings from

.. code:: bash

   dns_servers: ["8.8.8.8", "8.8.4.4"]
to

.. code:: bash

   dns_servers: ["<ip-address>"]

Also, you need to modify deploy.sh in apex/ci from “ntp_server="pool.ntp.org"” to “ntp_server="<ip-address>"” to reflect that fact we couldn’t reach outside NTP server, just use local time.

**9 Commands to deploy scenario :**

Following shows the commands used to deploy os-nosdn-kvm_ovs_dpdk-noha scenario behind the proxy:

.. code:: bash

   cd ~/apex/ci
   ./clean.sh
   ./dev_deploy_check.sh
   ./deploy.sh -v --ping-site <ping_ip-address> --dnslookup-site <dns_ip-address> -n ~/apex/config/network/intc_network_settings.yaml -d ~/apex/config/deploy/os-nosdn-kvm_ovs_dpdk-noha.yaml

**10 Accessing the Overcloud dashboard :**

If the deployment completes successfully, the last few output lines from the deployment will look like the following:

.. code:: bash

   INFO: Undercloud VM has been setup to NAT Overcloud public network
   Undercloud IP: <ip-address>, please connect by doing 'opnfv-util undercloud'
   Overcloud dashboard available at http://<ip-address>/dashboard
   INFO: Post Install Configuration Complete

**11 Accessing the Undercloud and Overcloud through command line :**

At the end of the deployment we obtain the Undercloud ip. One can login to the Undercloud and obtain the Overcloud ip as follows:

.. code:: bash

   cd ~/apex/ci/
   ./util.sh undercloud
   source stackrc
   nova list
   ssh heat-admin@<overcloud-ip>


OPNFV-Playground
~~~~~~~~~~~~~~~~

Install OPNFV-playground (the tool chain to deploy/test CI scenarios in fuel@opnfv, ):

.. code:: bash

    $ cd ~
    $ git clone https://github.com/jonasbjurel/OPNFV-Playground.git
    $ cd OPNFV-Playground/ci_fuel_opnfv/

- Follow the README.rst in this ~/OPNFV-Playground/ci_fuel_opnfv sub-holder to complete all necessary installation and setup.
- Section “RUNNING THE PIPELINE” in README.rst explain how to use this ci_pipeline to deploy/test CI test scenarios, you can also use

.. code:: bash

    ./ci_pipeline.sh --help  ##to learn more options.



``1 Downgrade paramiko package from 2.x.x to 1.10.0``

The paramiko package 2.x.x doesn’t work with OPNFV-playground  tool chain now, Jira ticket FUEL - 188 has been raised for the same.

Check paramiko package version by following below steps in your system:

.. code:: bash

   $ python
   Python 2.7.6 (default, Jun 22 2015, 17:58:13) [GCC 4.8.2] on linux2 Type "help", "copyright", "credits" or "license" for more information.

   >>> import paramiko
   >>> print paramiko.__version__
   >>> exit()

You will get the current paramiko package version, if it is 2.x.x, uninstall this version by

.. code:: bash

    $  sudo pip uninstall paramiko

Ubuntu 14.04 LTS has python-paramiko package (1.10.0), install it by

.. code:: bash

    $ sudo apt-get install python-paramiko


Verify it by following:

.. code:: bash

   $ python
   >>> import paramiko
   >>> print paramiko.__version__
   >>> exit()


``2  Clone the fuel@opnfv``

Check out the specific version of specific branch of fuel@opnfv

.. code:: bash

   $ cd ~
   $ git clone https://gerrit.opnfv.org/gerrit/fuel.git
   $ cd fuel
   By default it will be master branch, in-order to deploy on the Colorado/Danube branch, do:
   $ git checkout stable/Danube


``3 Creating the scenario``

Implement the scenario file as described in 3.1.4

``4 Deploying the scenario``

You can use the following command to deploy/test os-nosdn kvm_ovs_dpdk-(no)ha and os-nosdn-kvm_ovs_dpdk_bar-(no)ha scenario

.. code:: bash

   $ cd ~/OPNFV-Playground/ci_fuel_opnfv/

For os-nosdn-kvm_ovs_dpdk-ha :

.. code:: bash

   $ ./ci_pipeline.sh -r ~/fuel -i /root/fuel.iso -B -n intel-sc -s os-nosdn-kvm_ovs_dpdk-ha

For os-nosdn-kvm_ovs_dpdk_bar-ha:

.. code:: bash

   $ ./ci_pipeline.sh -r ~/fuel -i /root/fuel.iso -B -n intel-sc -s os-nosdn-kvm_ovs_dpdk_bar-ha

The “ci_pipeline.sh” first clones the local fuel repo, then deploys the
os-nosdn-kvm_ovs_dpdk-ha/os-nosdn-kvm_ovs_dpdk_bar-ha scenario from the given ISO, and run Functest
and Yarstick test.  The log of the deployment/test (ci.log)  can be found in
~/OPNFV-Playground/ci_fuel_opnfv/artifact/master/YYYY-MM-DD—HH.mm, where YYYY-MM-DD—HH.mm is the
date/time you start the “ci_pipeline.sh”.

Note:

.. code:: bash

   Check $ ./ci_pipeline.sh -h for further information.


Jenkins Project
~~~~~~~~~~~~~~~

os-nosdn-kvm_ovs_dpdk-(no)ha and os-nosdn-kvm_ovs_dpdk_bar-(no)ha scenario can be executed from the jenkins project :

    ``HA scenarios:``
        1.  "fuel-os-nosdn-kvm_ovs_dpdk-ha-baremetal-daily-master" (os-nosdn-kvm_ovs_dpdk-ha)
        2.  "fuel-os-nosdn-kvm_ovs_dpdk_bar-ha-baremetal-daily-master" (os-nosdn-kvm_ovs_dpdk_bar-ha)
        3.  "apex-os-nosdn-kvm_ovs_dpdk-ha-baremetal-master" (os-nosdn-kvm_ovs_dpdk-ha)

    ``NOHA scenarios:``
        1.  "fuel-os-nosdn-kvm_ovs_dpdk-noha-virtual-daily-master" (os-nosdn-kvm_ovs_dpdk-noha)
        2.  "fuel-os-nosdn-kvm_ovs_dpdk_bar-noha-virtual-daily-master" (os-nosdn-kvm_ovs_dpdk_bar-noha)
        3.  "apex-os-nosdn-kvm_ovs_dpdk-noha-baremetal-master" (os-nosdn-kvm_ovs_dpdk-noha)
