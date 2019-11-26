locals {
  vars= {webservers: vsphere_virtual_machine.vm[*].default_ip_address}
}

resource "local_file" "inventory" {
    content     = templatefile("template-files/templates/inventory.tmpl", {ipsWeb=vsphere_virtual_machine.vm[*].default_ip_address, ipsLb=vsphere_virtual_machine.vm-lb[*].default_ip_address, sudo_pass=var.password, csv=local.ips, ipPub=var.ipPub, count=0})
    filename = "../ansible/inventory/inventory-static.txt"
}
resource "null_resource" "ansible" {
    triggers = {
        webservers = join(",", vsphere_virtual_machine.vm[*].default_ip_address)
        loadbalancers = join(",", vsphere_virtual_machine.vm-lb[*].default_ip_address)

  }

    provisioner "local-exec" {

        command = "ansible-playbook -i '../ansible/inventory/inventory-static.txt'  --extra-vars '${jsonencode(local.vars)}'  ../ansible/site.yml " 
    }
   
}
