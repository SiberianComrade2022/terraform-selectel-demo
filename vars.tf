# Connection/Auth
variable "user_name" {
  description = "Used to initiate Provider OpenStack: 'user_name'"
}

variable "sel_account" {
  description = "Numeric ID as in my.selectel.ru"
}

variable "user_password" {
  description = "Used to initiate Provider OpenStack: 'password'"
}

variable "sel_token" {
  description = "Used to initiate Provider Selectel: 'token'"
}

variable "project_id" {
  description = "Used to initiate Provider OpenStack: 'tenant_id'"
}

variable "os_auth_url" {
  default     = "https://api.selvpc.ru/identity/v3"
  description = "Used to initiate Provider OpenStack: 'auth_url'"
}

variable "proctor_ip" {
  description = "External (public) IP address with mask /32 to verify the solution. Use 'curl ifconfig.ru' to find yours."
  type        = string
  default     = "127.0.0.2"
}


# Hardware configuration

variable "bastion_flavor" {
  default     = "SL1.1-1024" # 1GB, 1 Shared CPU, no disk
  description = "Bastion Flavor as in `openstack flavor list`"
}

variable "prom_flavor" {
  default     = "SL1.2-4096" # 4GB, 2 Shared CPU, no disk
  description = "Prometheus Flavor as in `openstack flavor list`"
}

variable "pool_flavor" {
  default     = "SL1.2-4096" # 4GB, 2 Shared CPU, no disk
  description = "Working horses Flavor as in `openstack flavor list`"
}

# openstack image list --public
variable "linux_image_name" {
  default = "Ubuntu 20.04 LTS 64-bit"
  type    = string
  validation {
    condition     = can(index(["Ubuntu 18.04 LTS 64-bit", "Ubuntu 20.04 LTS 64-bit", "Debian 9 (Stretch) 64-bit", "Debian 10 (Buster) 64-bit", "Debian 11 (Bullseye) 64-bit"], var.linux_image_name) >= 0)
    error_message = "Invalid image. Run 'openstack image list --public' to get list of available images."
  }
}

# Type of the network volume that the server is created from
variable "volume_type" {
  default     = "fast.ru-3a"
  description = "Network volume type as in 'openstack volume type list'"
  type        = string
  validation {
    condition     = can(index(["fast.ru-3b", "fast.ru-3a", "universal.ru-3b", "universal.ru-3a"], var.volume_type) >= 0)
    error_message = "Invalid Network Volume type, consult 'openstack volume type list'."
  }
}

variable "bastion_name" {
  default = "tf-bastion"
}

variable "prometheus_name" {
  default     = "tf-prometheus"
  description = "Hostname of the server running Prometheus"
}
variable "pool_prefix" {
  default = "tf-linux"
}

variable "replicas_count" {
  default     = 3
  description = "Number of servers with Docker and Nginx"
}

variable "keypair_name" {
  default     = "tf-key"
  description = "Name of pre-created Key uploaded to the console"
}

variable "ssh_private_key" {
  default = "ansible/id_rsa"
}

# Network settings

variable "dns_nameservers" {
  default = [
    "188.93.16.19",
    "188.93.17.19",
  ]
}

variable "external_net_name" {
  default     = "external-network"
  description = "Network name as in 'openstack network list --external'"
}

variable "network_name" {
  default = "network_1"
}

variable "subnet_cidr" {
  default = "10.209.035.0/24"
}

# https://kb.selectel.ru/docs/cloud/servers/about/locations/
variable "region" {
  default = "ru-3"
  type    = string
  validation {
    condition     = can(index(["ru-1", "ru-2", "ru-3"], var.region) >= 0)
    error_message = "Invalid Region, consult 'openstack region list'."
  }
}

# https://kb.selectel.ru/docs/cloud/servers/about/locations/
variable "server_zone" {
  default = "ru-3a"
  type    = string
  validation {
    condition     = can(index(["ru-1a", "ru-1b", "ru-1c", "ru-2a", "ru-2b", "ru-2c", "ru-3a", "ru-3b"], var.server_zone) >= 0)
    error_message = "Invalid Availability Zone."
  }
}

variable "router_name" {
  default = "tf_router_1"
}

variable "lb_components" {
  default = {
    listener_protocol      = "TCP"
    listener_protocol_port = 8080
    monitor_type           = "TCP"
    monitor_delay          = 20
    monitor_timeout        = 10
    monitor_retries        = 5
    # pool_lb_method         = "LEAST_CONNECTIONS"
    # Round Robin is better for LB demonstration purposes
    pool_lb_method       = "ROUND_ROBIN"
    pool_protocol        = "TCP"
    member_protocol_port = 80
  }
}

variable "lb_sngl_name" {
  default = "tf-lb-sngl"
}

variable "lb_sngl_flavor_uuid" {
  description = "Load Balancer Flavor as in 'openstack loadbalancer flavor list -c id -c name'"
  default     = "d4490352-a58a-44b7-b226-717cd7607c0e" # AMPH1.SNGL.2-1024
}

variable "prometheus_version" {
  default = "2.34.0"
}
variable "node_exporter_version" {
  default = "1.3.1"
}
variable "prometheus_path" {
  default     = "/etc/prometheus/"
  description = "Path to keep configuration and TLS keys for Prometheus and Node Exporter"
}

variable "tls_subject" {
  default = {
    common_name         = "nodex.selectel.ru"
    organization        = "SX, Z-Level LLC"
    organizational_unit = "Terraform"
    country             = "RU"
    postal_code         = "127000"
  }
}