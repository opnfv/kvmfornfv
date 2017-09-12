.. This work is licensed under a Creative Commons Attribution 4.0 International License.

.. http://creativecommons.org/licenses/by/4.0

==========================================
os-nosdn-kvm_ovs_dpdk-noha Description
==========================================

Introduction
------------

.. In this section explain the purpose of the scenario and the
   types of capabilities provided

The purpose of os-nosdn-kvm_ovs_dpdk-noha scenario testing is to test the No
High Availability deployment and configuration of OPNFV software suite
with OpenStack and without SDN software. This OPNFV software suite
includes OPNFV KVM4NFV latest software packages for Linux Kernel and
QEMU patches for achieving low latency. When deployed using Fuel, No High
Availability feature is achieved by deploying OpenStack multi-node setup with
1 controller and 3 computes nodes and using Apex the setup is with ! controller
and 1 compute.

KVM4NFV packages will be installed on compute nodes as part of deployment.
This scenario testcase deployment is happening on multi-node by using OPNFV Fuel
and Apex deployer.


**Using Fuel Installer**

Scenario Components and Composition
------------------------------------
.. In this section describe the unique components that make up the scenario,
.. what each component provides and why it has been included in order
.. to communicate to the user the capabilities available in this scenario.

This scenario deploys the No High Availability OPNFV Cloud based on the
configurations provided in no-ha_nfv-kvm_nfv-ovs-dpdk_heat_ceilometer_scenario.yaml.
This yaml file contains following configurations and is passed as an
argument to deploy.py script

* ``scenario.yaml:`` This configuration file defines translation between a
  short deployment scenario name(os-nosdn-kvm_ovs_dpdk-noha) and an actual deployment
  scenario configuration file(no-ha_nfv-kvm_nfv-ovs-dpdk_heat_ceilometer_scenario.yaml)

* ``deployment-scenario-metadata:`` Contains the configuration metadata like
  title,version,created,comment.

.. code:: bash

   deployment-scenario-metadata:
      title: NFV KVM and OVS-DPDK NOHA deployment
      version: 0.0.1
      created: Dec 20 2016
      comment: NFV KVM and OVS-DPDK

* ``stack-extensions:`` Stack extentions are opnfv added value features in form
  of a fuel-plugin.Plugins listed in stack extensions are enabled and
  configured. os-nosdn-kvm_ovs_dpdk-noha scenario currently uses KVM-1.0.0 plugin.

.. code:: bash

   stack-extensions:
      - module: fuel-plugin-kvm
        module-config-name: fuel-nfvkvm
        module-config-version: 1.0.0
        module-config-override:
          # Module config overrides

* ``dea-override-config:`` Used to configure the NO-HA mode,network segmentation
  types and role to node assignments.These configurations overrides
  corresponding keys in the dea_base.yaml and dea_pod_override.yaml.
  These keys are used to deploy multiple nodes(``1 controller,3 computes``)
  as mention below.

  * **Node 1**:
     - This node has MongoDB and Controller roles
     - The controller node runs the Identity service, Image Service, management portions of
       Compute and Networking, Networking plug-in and the dashboard
     - Uses VLAN as an interface

  * **Node 2**:
     - This node has compute and Ceph-osd roles
     - Ceph is a massively scalable, open source, distributed storage system
     - By default, Compute uses KVM as the hypervisor
     - Uses DPDK as an interface

  * **Node 3**:
     - This node has compute and Ceph-osd roles
     - Ceph is a massively scalable, open source, distributed storage system
     - By default, Compute uses KVM as the hypervisor
     - Uses DPDK as an interface

  * **Node 4**:
     - This node has compute and Ceph-osd roles
     - Ceph is a massively scalable, open source, distributed storage system
     - By default, Compute uses KVM as the hypervisor
     - Uses DPDK as an interface

  The below is the ``dea-override-config`` of the no-ha_nfv-kvm_nfv-ovs-dpdk_heat_ceilometer_scenario.yaml file.

.. code:: bash

   dea-override-config:
     fuel:
       FEATURE_GROUPS:
       - experimental
     environment:
       net_segment_type: vlan
     nodes:
     - id: 1
       interfaces: interfaces_vlan
       role: mongo,controller
     - id: 2
       interfaces: interfaces_dpdk
       role: ceph-osd,compute
       attributes: attributes_1
     - id: 3
       interfaces: interfaces_dpdk
       role: ceph-osd,compute
       attributes: attributes_1
     - id: 4
       interfaces: interfaces_dpdk
       role: ceph-osd,compute
       attributes: attributes_1

     attributes_1:
       hugepages:
         dpdk:
           value: 1024
         nova:
           value:
             '2048': 1024

     network:
       networking_parameters:
         segmentation_type: vlan
       networks:
       - cidr: null
         gateway: null
         ip_ranges: []
         meta:
           configurable: false
           map_priority: 2
           name: private
           neutron_vlan_range: true
           notation: null
           render_addr_mask: null
           render_type: null
           seg_type: vlan
           use_gateway: false
           vlan_start: null
         name: private
         vlan_start: null

     settings:
       editable:
         storage:
           ephemeral_ceph:
             description: Configures Nova to store ephemeral volumes in RBD. This works best if Ceph
             is enabled for volumes and images, too. Enables live migration of all types of Ceph
             backed VMs (without this option, live migration will only work with VMs launched from
             Cinder volumes).
             label: Ceph RBD for ephemeral volumes (Nova)
             type: checkbox
             value: true
             weight: 75
           images_ceph:
             description: Configures Glance to use the Ceph RBD backend to store images. If enabled,
             this option will prevent Swift from installing.
             label: Ceph RBD for images (Glance)
             restrictions:
             - settings:storage.images_vcenter.value == true: Only one Glance backend could be selected.
             type: checkbox
             value: true
             weight: 30

* ``dha-override-config:`` Provides information about the VM definition and
  Network config for virtual deployment.These configurations overrides
  the pod dha definition and points to the controller,compute and
  fuel definition files. The no-ha_nfv-kvm_nfv-ovs-dpdk_heat_ceilometer_scenario.yaml
  has no dha-config changes i.e., default configuration is used.

* os-nosdn-kvm_ovs_dpdk-noha scenario is successful when all the 4 Nodes are accessible,
  up and running.



**Note:**

* In os-nosdn-kvm_ovs_dpdk-noha scenario, OVS is installed on the compute nodes with DPDK configured

* Hugepages for DPDK are configured in the attributes_1 section of the
no-ha_nfv-kvm_nfv-ovs-dpdk_heat_ceilometer_scenario.yaml

* Hugepages are only configured for compute nodes

* This results in faster communication and data transfer among the compute nodes


Scenario Usage Overview
-----------------------

.. Provide a brief overview on how to use the scenario and the features available to the
.. user.  This should be an "introduction" to the userguide document, and explicitly link to it,
.. where the specifics of the features are covered including examples and API's

* The high availability feature is disabled and deploymet is done by deploy.py with
  noha_nfv-kvm_nfv-ovs-dpdk_heat_ceilometer_scenario.yaml as an argument.
* Install Fuel Master and deploy OPNFV Cloud from scratch on Hardware
  Environment:


Command to deploy the os-nosdn-kvm_ovs_dpdk-noha scenario:

.. code:: bash

        $ cd ~/fuel/ci/
        $ sudo ./deploy.sh -f -b file:///tmp/opnfv-fuel/deploy/config -l devel-pipeline -p default \
        -s no-ha_nfv-kvm_nfv-ovs-dpdk_heat_ceilometer_scenario.yaml -i file:///tmp/opnfv.iso

where,
    -b is used to specify the configuration directory

    -i is used to specify the image downloaded from artifacts.

**Note:**

.. code:: bash

         Check $ sudo ./deploy.sh -h for further information.

* os-nosdn-kvm_ovs_dpdk-noha scenario can be executed from the jenkins project
  "fuel-os-nosdn-kvm_ovs_dpdk-noha-baremetal-daily-master"
* This scenario provides the No High Availability feature by deploying
  1 controller,3 compute nodes and checking if all the 4 nodes
  are accessible(IP,up & running).
* Test Scenario is passed if deployment is successful and all 4 nodes have
  accessibility (IP , up & running).


**Using Apex Installer**

Scenario Components and Composition
-----------------------------------
.. In this section describe the unique components that make up the scenario,
.. what each component provides and why it has been included in order
.. to communicate to the user the capabilities available in this scenario.

This scenario is composed of common OpenStack services enabled by default,
including Nova, Neutron, Glance, Cinder, Keystone, Horizon.  Optionally and
by default, Tacker and Congress services are also enabled.  Ceph is used as
the backend storage to Cinder on all deployed nodes.

The os-nosdn-kvm_ovs_dpdk-noha.yaml file contains following configurations and
is passed as an argument to deploy.sh script.

* ``global-params:`` Used to define the global parameter and there is only one
  such parameter exists,i.e, ha_enabled

.. code:: bash

   global-params:
     ha_enabled: false

* ``deploy_options:`` Used to define the type of SDN controller, configure the
  tacker, congress, service functioning chaining support(sfc) for ODL and ONOS,
  configure ODL with SDNVPN support, which dataplane to use for overcloud
  tenant networks, whether to run the kvm real time kernel (rt_kvm) in the
  compute node(s) to reduce the network latencies caused by network function
  virtualization and whether to install and configure fdio functionality in the
  overcloud

.. code:: bash

   deploy_options:
     sdn_controller: false
     tacker: true
     congress: true
     sfc: false
     vpn: false
     rt_kvm: true
     dataplane: ovs_dpdk

* ``performance:`` Used to set performance options on specific roles. The valid
  roles are 'Compute', 'Controller' and 'Storage', and the valid sections are
  'kernel' and 'nova'

.. code:: bash

   performance:
     Controller:
       kernel:
         hugepages: 1024
         hugepagesz: 2M
     Compute:
       kernel:
         hugepagesz: 2M
         hugepages: 2048
         intel_iommu: 'on'
         iommu: pt
       ovs:
         socket_memory: 1024
         pmd_cores: 2
         dpdk_cores: 1

Scenario Usage Overview
-----------------------
.. Provide a brief overview on how to use the scenario and the features available to the
.. user.  This should be an "introduction" to the userguide document, and explicitly link to it,
.. where the specifics of the features are covered including examples and API's

* The high availability feature can be acheived by executing deploy.sh with
  os-nosdn-kvm_ovs_dpdk-noha.yaml as an argument.

* Build the undercloud and overcloud images as mentioned below:

.. code:: bash

   cd ~/apex/build/
   make images-clean
   make images

* Command to deploy os-nosdn-kvm_ovs_dpdk-noha scenario:

.. code:: bash

   cd ~/apex/ci/
   ./clean.sh
   ./dev_dep_check.sh
   ./deploy.sh -v --ping-site <ping_ip-address> --dnslookup-site <dns_ip-address> -n \
   ~/apex/config/network/intc_network_settings.yaml -d ~/apex/config/deploy/os-nosdn-kvm_ovs_dpdk-noha.yaml

where,
    -v is used for virtual deployment
    -n is used for providing the network configuration file
    -d is used for providing the scenario configuration file


References
----------

For more information on the OPNFV Euphrates release, please visit
http://www.opnfv.org/Euphrates
