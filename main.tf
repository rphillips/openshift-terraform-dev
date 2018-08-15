terraform {
  required_version = ">= 0.10.7"
}

variable "master_count" {
  type = "string"
  default = "1"
}

variable "master_memory" {
  type = "string"
  default = "2048"
}

variable "infra_count" {
  type = "string"
  default = "1"
}

variable "infra_memory" {
  type = "string"
  default = "1024"
}

variable "compute_count" {
  type = "string"
  default = "1"
}

variable "compute_memory" {
  type = "string"
  default = "2048"
}

variable "ssh_pub_key" {
  type = "string"
  default = ""
}

variable "cloud_image" {
  type = "string"
  default = "file:///Fedora-Cloud-Base-27-1.6.x86_64.qcow2"
}

variable "network_subnets" {
  type = "list"
  default = ["10.7.1.0/16"]
}

provider "libvirt" {
  uri = "qemu:///system"
}

provider "template" {
  version = "~> 1.0"
}

resource "libvirt_cloudinit" "commoninit" {
  name           = "commoninit.iso"
  ssh_authorized_key = "${var.ssh_pub_key}"
}

resource "libvirt_volume" "fedora-cloud" {
  name = "fedora-cloud"
  source = "${var.cloud_image}"
}

resource "libvirt_volume" "master_volume" {
  name = "${var.cluster_name}-master-vm${count.index}"
  base_volume_id = "${libvirt_volume.fedora-cloud.id}"
  count = "${var.master_count}"
}

resource "libvirt_volume" "infra_volume" {
  name = "${var.cluster_name}-infra-vm${count.index}"
  base_volume_id = "${libvirt_volume.fedora-cloud.id}"
  count = "${var.infra_count}"
}

resource "libvirt_volume" "compute_volume" {
  name = "${var.cluster_name}-compute-vm${count.index}"
  base_volume_id = "${libvirt_volume.fedora-cloud.id}"
  count = "${var.compute_count}"
}

resource "libvirt_network" "vm_network" {
  name = "${var.cluster_name}_vm_network"
  addresses = "${var.network_subnets}"
}

resource "libvirt_domain" "masters" {
  count = "${var.master_count}"
  name = "${var.cluster_name}-master-${count.index}"
  memory = "${var.master_memory}"
  vcpu = 1
  cloudinit = "${libvirt_cloudinit.commoninit.id}"
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }
  disk {
    volume_id = "${element(libvirt_volume.master_volume.*.id, count.index)}"
  }
  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
  network_interface {
    network_name = "${var.cluster_name}_vm_network"
    hostname   = "${var.cluster_name}-master-${count.index}"
    wait_for_lease = 1
  }
}

resource "libvirt_domain" "infra" {
  count = "${var.infra_count}"
  name = "${var.cluster_name}-infra-${count.index}"
  memory = "${var.infra_memory}"
  vcpu = 1
  cloudinit = "${libvirt_cloudinit.commoninit.id}"
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }
  disk {
    volume_id = "${element(libvirt_volume.infra_volume.*.id, count.index)}"
  }
  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
  network_interface {
    network_name = "${var.cluster_name}_vm_network"
    hostname   = "${var.cluster_name}-infra-${count.index}"
    wait_for_lease = 1
  }
}

resource "libvirt_domain" "compute" {
  count = "${var.compute_count}"
  name = "${var.cluster_name}-compute-${count.index}"
  memory = "${var.compute_memory}"
  vcpu = 1
  cloudinit = "${libvirt_cloudinit.commoninit.id}"
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }
  disk {
    volume_id = "${element(libvirt_volume.compute_volume.*.id, count.index)}"
  }
  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
  network_interface {
    network_name = "${var.cluster_name}_vm_network"
    hostname   = "${var.cluster_name}-compute-${count.index}"
    wait_for_lease = 1
  }
}

output "ip_masters" {
  value = "${flatten(libvirt_domain.masters.*.network_interface.0.addresses)}"
}
output "ip_infra" {
  value = "${flatten(libvirt_domain.infra.*.network_interface.0.addresses)}"
}
output "ip_compute" {
  value = "${flatten(libvirt_domain.compute.*.network_interface.0.addresses)}"
}
