
# Create a volume for the VM
resource "libvirt_volume" "ubuntu_qcow2" {
  name   = "${var.vm_hostname}.qcow2"
  pool   = "default"
  source = var.ubuntu_image_url
  format = "qcow2"
}

resource "null_resource" "resize_volume" {
  depends_on = [libvirt_volume.ubuntu_qcow2]

  provisioner "local-exec" {
    command = "sudo qemu-img resize /var/lib/libvirt/images/${var.vm_hostname}.qcow2 30G"
  }
}

# Cloud-init configuration
resource "libvirt_cloudinit_disk" "cloudinit" {
  name = "${var.vm_hostname}-cloudinit.iso"
  pool = "default"
  user_data = templatefile("${path.module}/cloud_init.cfg", {
    hostname         = var.vm_hostname
    ssh_username     = var.ssh_username
    ssh_public_key   = file("${var.ssh_private_key}.pub")
    metallb_ip_range = var.metallb_ip_range
    static_ip        = var.static_ip
    gateway_ip       = var.gateway_ip
  })
}

# Define the VM
resource "libvirt_domain" "ubuntu_vm" {
  name   = var.vm_hostname
  memory = 8192
  vcpu   = 4
  cpu {
    mode = "host-passthrough"
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit.id

  network_interface {
    bridge = "br0"
  }

  disk {
    volume_id = libvirt_volume.ubuntu_qcow2.id
  }

  console {
    type        = "pty"
    target_port = "0"
  }

  # Ensure the VM starts after resizing
  depends_on = [null_resource.resize_volume]
}

# Wait for SSH to be ready
resource "null_resource" "wait_for_ssh" {
  provisioner "local-exec" {
    command = <<EOT
      for i in {1..30}; do
        ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i ${var.ssh_private_key} ${var.ssh_username}@${var.static_ip} "echo SSH is up" && break
        echo "Waiting for SSH to be ready..."
        sleep 10
      done
    EOT
  }

  depends_on = [libvirt_domain.ubuntu_vm]
}


resource "null_resource" "copy_microk8s_config" {
  depends_on = [null_resource.wait_for_ssh]

  provisioner "local-exec" {
    command = <<EOT
      ssh-keygen -R ${var.static_ip} -f ~/.ssh/known_hosts -q || true
      scp -o StrictHostKeyChecking=no -i ${var.ssh_private_key} ${var.ssh_username}@${var.static_ip}:/home/${var.ssh_username}/config ~/.kube/microk8s-${var.vm_hostname}-config
    EOT
  }
}
