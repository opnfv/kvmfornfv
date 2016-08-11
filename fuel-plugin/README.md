KVM Plugin for Fuel
================================

KVM plugin
-----------------------

Overview
--------

New fuel plugin fuel-plugin-kvm is to deploy KVM enhancements for NFV

Requirements
------------

| Requirement                      | Version/Comment |
|----------------------------------|-----------------|
| Mirantis OpenStack compatibility | 9.0             |

Recommendations
---------------

None.

Limitations
-----------

None.

Build Guide
===========

Buiding system pre-requistes
----------------------------
1. Ubuntu 14.04 LTS desktop or server
2. Minimum 4 CPU cores, 6 GB RAM, and 200 GB available hard drive space
3. "VirtualBox" and "vagrant" installed

Buid instruction
----------------
1. Clone the kvmfornfv repo from https://gerrit.opnfv.org/gerrit/kvmfornfv by
   "git clone https://gerrit.opnfv.org/gerrit/kvmfornfv".
2. You can modify the kernel code in kvmfornfv/kernel as you want.
3. Go to kvmfornfv/fuel-plugin/vagrant, type "vagrant destroy -f; vagrant up;
   vagarant destroy -f", the building will start.
4. When the building completes, you should find the built fuel-plugin-kvm in
   kvmfornfv/fuel-plugin/vagrant with the name as "fuel-plugin-kvm-0.9-0.9.0-1.noarch.rpm",
   where "0.9-0.9.0-1" is the version information for this plugin, this version info
   may be changed in future. The built plugin incules the changes you made.

Installation Guide
==================
1. Move the built fuel-pluginn-kvm to the Fuel Master node with secure copy (scp):
      scp fuel-plugin-kvm-0.9-0.9.0-1.noarch.rpm root@<the_Fuel_Master_node_IP address>:
2. While logged in Fuel Masternode, install the KVM plugin by typing:
        fuel plugins --install fuel-plugin-kvm-0.9-0.9.0-1.noarch.rpm
3. Check if the plugin was installed successfully by typing "fuel plugins", the folowing
   should appear:

        id | name             | version | package_version | release
        ---+------------------+---------+-----------------+--------------------
        1  | fuel-plugin-kvm  | 0.9.0   | 4.0.0           | ubuntu (mitaka-9.0)
4. Plugin is ready to use and can be enabled on the Settings tab of the Fuel web UI.


User Guide
==========

KVM plugin configuration
---------------------------------------------
1. Create a new environment with the Fuel UI wizard.
2. Click on the Settings tab of the Fuel web UI.
3. Scroll down the page, select the plugin checkbox.


Testing
-------
None.

Known issues
------------
None.

Contributors
------------
* davi.j.chou@intel.com, ruijing.guo@intel.comi, ling.y.yu@intel.com
