variable "vm_hostname" {
  description = "VM hostname"
  default     = "ubuntu2404-vm"
}

variable "libvirt_disk_path" {
  description = "Path for libvirt pool"
  default     = "/var/lib/libvirt/images"
}

variable "ubuntu_image_url" {
  description = "Ubuntu 24.04 image"
  default     = "https://cloud-images.ubuntu.com/releases/noble/release/ubuntu-24.04-server-cloudimg-amd64.img"
}

variable "ssh_username" {
  description = "SSH user for the VM"
  default     = "ubuntu"
}

variable "ssh_private_key" {
  description = "Path to SSH private key"
  default     = "~/.ssh/lieranderl_github"
}

variable "metallb_ip_range" {
  description = "Metallb IP range"
  default     = "192.168.122.25-192.168.122.28"
}

variable "static_ip" {
  type    = string
  default = "192.168.122.30"
}

variable "gateway_ip" {
  type    = string
  default = "192.168.122.1"
}
