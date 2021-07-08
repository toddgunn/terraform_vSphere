# Configure the VMware vSphere Provider
provider "vsphere" {
  user           = "toddgunn@VSPHERE.LOCAL"
  password       = "p1p1n5THeG8tentert@iner"
  vsphere_server = "157.201.228.240" 

  # if you have a self-signed cert
  allow_unverified_ssl = true
}


data "vsphere_datacenter" "dc" {
  name = "CIT"
}

data "vsphere_datastore_cluster" "datastore_cluster" {
  name          = "CITF700"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "compute_cluster" {
  name          = "UCS-A"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = data.vsphere_compute_cluster.compute_cluster.id
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "353-Public"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_folder" "folder" {
    path = "CIT-Intern"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "terraformed_vm"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore_cluster.datastore_cluster.id

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
    datastore_id = data.vsphere_datacenter.dc.id
    path = "UCS ESXi v101 - SMIF700/!-ISOs/CIT112/ubuntu-20.04.2.0-desktop-amd64.iso"
  }
}
