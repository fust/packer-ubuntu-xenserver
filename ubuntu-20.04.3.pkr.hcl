packer {
  required_plugins {
   xenserver= {
      version = ">= v0.3.2"
      source = "github.com/ddelnano/xenserver"
    }
  }
}

variable "remote_host" {
  type        = string
  description = "The ip or fqdn of your XenServer. This will be pulled from the env var 'PKR_VAR_XAPI_HOST'"
  sensitive   = true
  default     = null
}

variable "remote_password" {
  type        = string
  description = "The password used to interact with your XenServer. This will be pulled from the env var 'PKR_VAR_XAPI_PASSWORD'"
  sensitive   = true
  default     = null
}

variable "remote_username" {
  type        = string
  description = "The username used to interact with your XenServer. This will be pulled from the env var 'PKR_VAR_XAPI_USERNAME'"
  sensitive   = true
  default     = null

}

variable "sr_iso_name" {
  type        = string
  default     = ""
  description = "The ISO-SR to packer will use"

}

variable "sr_name" {
  type        = string
  default     = ""
  description = "The name of the SR to packer will use"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "") 
}


source "xenserver-iso" "ubuntu-2004" {
  iso_checksum      = "f8e3086f3cea0fb3fefb29937ab5ed9d19e767079633960ccb50e76153effc98"
  iso_checksum_type = "sha256"
  iso_url           = "http://releases.ubuntu.com/20.04/ubuntu-20.04.3-live-server-amd64.iso"

  sr_iso_name    = var.sr_iso_name
  sr_name        = var.sr_name
  tools_iso_name = "guest-tools.iso"

  remote_host     = var.remote_host
  remote_password = var.remote_password
  remote_username = var.remote_username

  vm_name         = "packer-ubuntu-20.04.3-amd64-${local.timestamp}"
  vm_description  = "Build started: ${local.timestamp}"
  vm_memory       = 4096
  vcpus_max       = 4
  vcpus_atstartup = 2
  disk_size       = 20000

  http_directory = "http/ubuntu-2004"
  boot_command   = [
    "<esc><wait10><wait10><f6><wait10> autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/<enter><wait10>",
    "<f6><wait10><esc><wait10> autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/<enter><wait>"
  ]
  boot_wait      = "10s"

  ssh_username            = "vagrant"
  ssh_password            = "vagrant"
  ssh_wait_timeout        = "60000s"
  ssh_handshake_attempts  = 10000

  output_directory = "packer-ubuntu-20.04.3-iso"
  keep_vm          = "on_success"
  format           = "none"
}

build {
  sources = ["xenserver-iso.ubuntu-20.04.3"]

  provisioner "file" {
    destination = "/tmp/ansible.pub"
    source      = "${path.root}/public_keys/id_rsa_ansible.pub"
  }

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "${path.root}/scripts/ansible.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "${path.root}/scripts/setup.sh"
  }

  provisioner "ansible-local" {
    galaxy_file   = "${path.root}/requirements.yml"
    playbook_file = "${path.root}/ansible/main.yml"
  }

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "${path.root}/scripts/cleanup.sh"
  }
}
