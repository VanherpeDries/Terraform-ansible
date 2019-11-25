data "vsphere_datacenter" "dc" {
  name = "Labo"
}


data "vsphere_datastore" "datastore" {
  name          = "FreeNAS-FS"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "DRS-Cluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "ubuntu-1804-tpl"
  datacenter_id = data.vsphere_datacenter.dc.id
}
resource "vsphere_folder" "folder" {
  path          = "dries-webfarm"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}
