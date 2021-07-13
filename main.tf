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

data "vsphere_datastore" "datastore"{
  name = "UCS ESXi v101 - SMIF700"
  datacenter_id = data.vsphere_datacenter.dc.id
}

// Assigns a random host to UCS-A
data "vsphere_compute_cluster" "compute_cluster" {
  name          = "UCS-A"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "CIT/CITdvSwitch/353-Public"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = "terraformed_vm"
  resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
  datastore_cluster_id     = data.vsphere_datastore_cluster.datastore_cluster.id

  folder = "/CIT/vm/CIT-Intern"
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

  cdrom {
    path = "!-ISOs/CIT112/ubuntu-20.04.2.0-desktop-amd64.iso"
    datastore_id = data.vsphere_datastore.datastore.id
  }
}
