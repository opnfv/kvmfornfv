.. This work is licensed under a Creative Commons Attribution 4.0 International License.

.. http://creativecommons.org/licenses/by/4.0

============================
os-nosdn-kvm-ha Description
============================

Introduction
-------------

.. In this section explain the purpose of the scenario and the
   types of capabilities provided

The purpose of os-nosdn-kvm-ha scenario testing is to test the
High Availability deployment and configuration of OPNFV software suite
with OpenStack and without SDN software. This OPNFV software suite
includes OPNFV KVM4NFV latest software packages for Linux Kernel and
QEMU patches for achieving low latency. High Availability feature is achieved
by deploying OpenStack multi-node setup with 3 controllers and 2 computes nodes

KVM4NFV packages will be installed on compute nodes as part of deployment.
This scenario testcase deployment is happening on multi-node by using
OPNFV Fuel deployer.

Scenario Components and Composition
-----------------------------------
.. In this section describe the unique components that make up the scenario,
.. what each component provides and why it has been included in order
.. to communicate to the user the capabilities available in this scenario.

This scenario deploys the High Availability OPNFV Cloud based on the
configurations provided in ha_nfv-kvm_heat_ceilometer_scenario.yaml.
This yaml file contains following configurations and is passed as an
argument to deploy.py script

* ``scenario.yaml:`` This configuration file defines translation between a
  short deployment scenario name(os-nosdn-kvm-ha) and an actual deployment
  scenario configuration file(ha_nfv-kvm_heat_ceilometer_scenario.yaml)

* ``deployment-scenario-metadata:`` Contains the configuration metadata like
  title,version,created,comment.

* ``stack-extensions:`` Stack extentions are opnfv added value features in form
  of a fuel-plugin.Plugins listed in stack extensions are enabled and
  configured.

* ``dea-override-config:`` Used to configure the HA mode,network segmentation
  types and role to node assignments.These configurations overrides
  corresponding keys in the dea_base.yaml and dea_pod_override.yaml.
  These keys are used to deploy multiple nodes(3 controllers,2 computes)
  as mention below.

  * **Node 1**: This node has MongoDB and Controller roles. The controller
    node runs the Identity service, Image Service, management portions of
    Compute and Networking, Networking plug-in and the dashboard. The
    Telemetry service which was designed to support billing systems for
    OpenStack cloud resources uses a NoSQL database to store information.
    The database typically runs on the controller node.

  * **Node 2**: This node has Controller and Ceph-osd roles. Ceph is a
    massively scalable, open source, distributed storage system. It is
    comprised of an object store, block store and a POSIX-compliant distributed
    file system. Enabling Ceph,  configures Nova to store ephemeral volumes in
    RBD, configures Glance to use the Ceph RBD backend to store images,
    configures Cinder to store volumes in Ceph RBD images and configures the
    default number of object replicas in Ceph.

  * **Node 3**: This node has Controller role in order to achieve high
    availability.

  * **Node 4**: This node has Compute role. The compute node runs the
    hypervisor portion of Compute that operates tenant virtual machines
    or instances. By default, Compute uses KVM as the hypervisor.

  * **Node 5**: This node has compute role.

* ``dha-override-config:`` Provides information about the VM definition and
  Network config for virtual deployment.These configurations overrides
  the pod dha definition and points to the controller,compute and
  fuel definition files.

* os-nosdn-kvm-ha scenario is successful when all the 5 Nodes are accessible,
  up and running

Scenario Usage Overview
-----------------------
.. Provide a brief overview on how to use the scenario and the features available to the
.. user.  This should be an "introduction" to the userguide document, and explicitly link to it,
.. where the specifics of the features are covered including examples and API's

* The high availability feature can be acheived by executing deploy.py with
  ha_nfv-kvm_heat_ceilometer_scenario.yaml as an argument.
* Install Fuel Master and deploy OPNFV Cloud from scratch on Hardware
  Environment:

  -Example:

.. code:: bash

  sudo python deploy.py -iso ~/ISO/opnfv.iso -dea ~/CONF/hardware/dea.yaml -dha ~/CONF/hardware/dha.yaml -s /mnt/images -b pxebr -log ~/Deployment-888.log.tar.gz

* Install Fuel Master and deploy OPNFV Cloud from scratch on Virtual
  Environment:

  -Example:

.. code:: bash

  sudo python deploy.py -iso ~/ISO/opnfv.iso -dea ~/CONF/virtual/dea.yaml -dha ~/CONF/virtual/dha.yaml -s /mnt/images -log ~/Deployment-888.log.tar.gz

* os-nosdn-kvm-ha scenario can be executed from the jenkins project
  "fuel-os-nosdn-kvm-ha-baremetal-daily-master"
* This scenario provides the High Availability feature by deploying
  3 controller,2 compute nodes and checking if all the 5 nodes
  are accessible(IP,up & running).
* Test Scenario is passed if deployment is successful and all 5 nodes have
  accessibility (IP , up & running).
* Observed that scenario is not running any testcase on top of deployment.

Known Limitations, Issues and Workarounds
-----------------------------------------
.. Explain any known limitations here.

* Test scenario os-nosdn-kvm-ha result is not stable. After node reboot
  triggered by kvm plugin, sometimes puppet agent (mcollective) is not
  responding with in the given time.

References
----------

For more information on the OPNFV Euphrates release, please visit
http://www.opnfv.org/euphrates
