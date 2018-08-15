terraform {
  required_version = ">= 0.10.7"
}

variable "master_count" {
  type = "string"
  default = "1"
}

variable "infra_count" {
  type = "string"
  default = "1"
}

variable "compute_count" {
  type = "string"
  default = "1"
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

resource "libvirt_cloudinit" "commoninit" {
  name           = "commoninit.iso"
  ssh_authorized_key = "${var.ssh_pub_key}"
}

resource "libvirt_volume" "fedora-cloud" {
  name = "fedora-cloud"
  source = "${var.cloud_image}"
}

resource "libvirt_volume" "volume" {
  name = "vm${count.index}"
  base_volume_id = "${libvirt_volume.fedora-cloud.id}"
  count = "${master_count + etcd_count + compute_count}"
}

resource "libvirt_network" "vm_network" {
  name = "vm_network"
  addresses = "${var.network_subnets}"
}

resource "libvirt_domain" "masters" {
  count = "${master_count}"
  name = "master-${count.index}"
  memory = "2048"
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
    volume_id = "${element(libvirt_volume.volume.*.id, count.index)}"
  }
  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
  network_interface {
    network_name = "vm_network"
  }
}

resource "libvirt_domain" "etcd" {
  count = 1
  name = "etcd-${count.index}"
  memory = "1024"
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
    volume_id = "${element(libvirt_volume.volume.*.id, count.index)}"
  }
  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
  network_interface {
    network_name = "vm_network"
  }
}

resource "libvirt_domain" "compute" {
  count = 1
  name = "compute-${count.index}"
  memory = "1024"
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
    volume_id = "${element(libvirt_volume.volume.*.id, count.index)}"
  }
  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
  network_interface {
    network_name = "vm_network"
  }
}

