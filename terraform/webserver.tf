
locals {
  ips = "${csvdecode(file("iptjes-credentials.csv"))}"
  portnum = "22"
  ipPub  = "172.23.82.60"

}

resource "vsphere_virtual_machine" "vm" {
  count            = var.webserver_count
  name             = "${var.hostname}-${count.index + 1}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = vsphere_folder.folder.path
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    name             = "disk0.vmdk"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "${var.hostname}-${count.index + 1}"
        domain    = "howest.local"
      }
      network_interface {
      }
    }
  }
  provisioner "file" {
    connection {
    type     = "ssh"
    user     = var.user
    password = var.password
    host     = local.ipPub
    port     = [for ip in local.ips : tostring(ip.port) if ip.ip == self.guest_ip_addresses[0]][0]
    agent    = "false"
    }
      source      = "./template-files"
      destination = "/home/student/template-files"
  }
  provisioner "remote-exec" {
    connection {
    type     = "ssh"
    user     = var.user
    password = var.password
    host     = local.ipPub
    port     = [for ip in local.ips : tostring(ip.port) if ip.ip == self.guest_ip_addresses[0]][0]
    agent    = "false"
    }
    inline = [
      "echo ${var.password} | sudo -S rm /etc/ssh/sshd_config",
      "echo ${var.password} | sudo -S mkdir .ssh",
      "echo ${var.password} | sudo -S cp template-files/sshd_config /etc/ssh/",
      "echo ${var.password} | sudo -S cp template-files/id_rsa.pub .ssh/authorized_keys",
      "echo ${var.password} | sudo -S service ssh restart"
    ]
  }
}

