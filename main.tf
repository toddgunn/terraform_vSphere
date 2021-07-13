# Configure the VMware vSphere provider
provider "vsphere" {
  user           = ""
  password       = ""
  vsphere_server = "157.201.228.240" 

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "CIT"
}

data "vsphere_datastore_cluster" "datastore_cluster" {
  name          = "CITF700"
  datacenter_id = data.vsphere_datacenter.dc.id
}

// Assigns a random host to UCS-A
data "vsphere_compute_cluster" "compute_cluster" {
  name          = "UCS-A"
  datacenter_id = data.vsphere_datacenter.dc.id
}

// There's an error that occurs when using 353-Public. It can't tell if you want the network or the distributed 
//port group
data "vsphere_network" "network" {
  name          = "353-S1-Team1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

// Doesn't put the vm in the CIT-Intern folder, instead it places it inside of CIT
data "vsphere_folder" "folder" {
    path = "CIT-Intern"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "terraformed_vm"
  resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
  datastore_cluster_id     = data.vsphere_datastore_cluster.datastore_cluster.id

  wait_for_guest_net_timeout = 0

  num_cpus = 2
  memory   = 2048
  guest_id = "ubuntu64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = 20
  }

// There's an issue with the path variable
 /* cdrom {
    datastore_id = data.vsphere_datacenter.dc.id
    path = "UCS ESXi v101 - SMIF700/!-ISOs/CIT112/ubuntu-20.04.2.0-desktop-amd64.iso"
  }*/
}
