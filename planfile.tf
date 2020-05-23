 # google_compute_address.controller_ip[0] will be created
  + resource "google_compute_address" "controller_ip" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "controller0-address"
      + network_tier       = (known after apply)
      + project            = (known after apply)
      + purpose            = (known after apply)
      + region             = (known after apply)
      + self_link          = (known after apply)
      + subnetwork         = (known after apply)
      + users              = (known after apply)
    }

  # google_compute_address.controller_ip[1] will be created
  + resource "google_compute_address" "controller_ip" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "controller1-address"
      + network_tier       = (known after apply)
      + project            = (known after apply)
      + purpose            = (known after apply)
      + region             = (known after apply)
      + self_link          = (known after apply)
      + subnetwork         = (known after apply)
      + users              = (known after apply)
    }

  # google_compute_address.controller_ip[2] will be created
  + resource "google_compute_address" "controller_ip" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "controller2-address"
      + network_tier       = (known after apply)
      + project            = (known after apply)
      + purpose            = (known after apply)
      + region             = (known after apply)
      + self_link          = (known after apply)
      + subnetwork         = (known after apply)
      + users              = (known after apply)
    }

  # google_compute_address.lb_ip[0] will be created
  + resource "google_compute_address" "lb_ip" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "kubernetes-the-hard-way"
      + network_tier       = (known after apply)
      + project            = (known after apply)
      + purpose            = (known after apply)
      + region             = (known after apply)
      + self_link          = (known after apply)
      + subnetwork         = (known after apply)
      + users              = (known after apply)
    }

  # google_compute_address.worker_ip[0] will be created
  + resource "google_compute_address" "worker_ip" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "worker0-address"
      + network_tier       = (known after apply)
      + project            = (known after apply)
      + purpose            = (known after apply)
      + region             = (known after apply)
      + self_link          = (known after apply)
      + subnetwork         = (known after apply)
      + users              = (known after apply)
    }

  # google_compute_address.worker_ip[1] will be created
  + resource "google_compute_address" "worker_ip" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "worker1-address"
      + network_tier       = (known after apply)
      + project            = (known after apply)
      + purpose            = (known after apply)
      + region             = (known after apply)
      + self_link          = (known after apply)
      + subnetwork         = (known after apply)
      + users              = (known after apply)
    }

  # google_compute_address.worker_ip[2] will be created
  + resource "google_compute_address" "worker_ip" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "worker2-address"
      + network_tier       = (known after apply)
      + project            = (known after apply)
      + purpose            = (known after apply)
      + region             = (known after apply)
      + self_link          = (known after apply)
      + subnetwork         = (known after apply)
      + users              = (known after apply)
    }

  # google_compute_firewall.external_firewall will be created
  + resource "google_compute_firewall" "external_firewall" {
      + creation_timestamp = (known after apply)
      + destination_ranges = (known after apply)
      + direction          = (known after apply)
      + id                 = (known after apply)
      + name               = "kubernetes-the-hard-way-allow-external"
      + network            = "kubernetes-the-hard-way"
      + priority           = 1000
      + project            = (known after apply)
      + self_link          = (known after apply)
      + source_ranges      = [
          + "0.0.0.0/0",
        ]

      + allow {
          + ports    = [
              + "22",
              + "6443",
            ]
          + protocol = "tcp"
        }
      + allow {
          + ports    = []
          + protocol = "icmp"
        }
    }

  # google_compute_firewall.healthcheck_firewall will be created
  + resource "google_compute_firewall" "healthcheck_firewall" {
      + creation_timestamp = (known after apply)
      + destination_ranges = (known after apply)
      + direction          = (known after apply)
      + id                 = (known after apply)
      + name               = "kubernetes-the-hard-way-allow-health-check"
      + network            = "kubernetes-the-hard-way"
      + priority           = 1000
      + project            = (known after apply)
      + self_link          = (known after apply)
      + source_ranges      = [
          + "34.0.0.0/8",
          + "35.0.0.0/8",
          + "46.0.0.0/8",
        ]

      + allow {
          + ports    = []
          + protocol = "tcp"
        }
    }

  # google_compute_firewall.internal_firewall will be created
  + resource "google_compute_firewall" "internal_firewall" {
      + creation_timestamp = (known after apply)
      + destination_ranges = (known after apply)
      + direction          = (known after apply)
      + id                 = (known after apply)
      + name               = "kubernetes-the-hard-way-allow-internal"
      + network            = "kubernetes-the-hard-way"
      + priority           = 1000
      + project            = (known after apply)
      + self_link          = (known after apply)
      + source_ranges      = [
          + "10.200.0.0/16",
          + "10.240.0.0/24",
        ]

      + allow {
          + ports    = []
          + protocol = "icmp"
        }
      + allow {
          + ports    = []
          + protocol = "tcp"
        }
      + allow {
          + ports    = []
          + protocol = "udp"
        }
    }

  # google_compute_forwarding_rule.default will be created
  + resource "google_compute_forwarding_rule" "default" {
      + creation_timestamp    = (known after apply)
      + id                    = (known after apply)
      + ip_address            = (known after apply)
      + ip_protocol           = (known after apply)
      + ip_version            = (known after apply)
      + load_balancing_scheme = "EXTERNAL"
      + name                  = "kubernetes-forwarding-rule"
      + network               = (known after apply)
      + network_tier          = (known after apply)
      + port_range            = "6443"
      + project               = (known after apply)
      + region                = (known after apply)
      + self_link             = (known after apply)
      + service_name          = (known after apply)
      + subnetwork            = (known after apply)
      + target                = (known after apply)
    }

  # google_compute_http_health_check.default will be created
  + resource "google_compute_http_health_check" "default" {
      + check_interval_sec  = 5
      + creation_timestamp  = (known after apply)
      + description         = "kubernetes health check"
      + healthy_threshold   = 2
      + host                = "kubernetes.default.svc.cluster.local"
      + id                  = (known after apply)
      + name                = "kubernetes"
      + port                = 80
      + project             = (known after apply)
      + request_path        = "/healthz"
      + self_link           = (known after apply)
      + timeout_sec         = 5
      + unhealthy_threshold = 2
    }

  # google_compute_instance.controller[0] will be created
  + resource "google_compute_instance" "controller" {
      + can_ip_forward       = true
      + cpu_platform         = (known after apply)
      + deletion_protection  = false
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + machine_type         = "n1-standard-1"
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "controller-0"
      + project              = (known after apply)
      + self_link            = (known after apply)
      + tags                 = [
          + "controller",
          + "kubernetes-the-hard-way",
        ]
      + tags_fingerprint     = (known after apply)
      + zone                 = "europe-west3-a"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + image  = "centos-cloud/centos-7-v20200309"
              + labels = (known after apply)
              + size   = 200
              + type   = (known after apply)
            }
        }

      + network_interface {
          + name               = (known after apply)
          + network            = (known after apply)
          + network_ip         = "10.240.0.10"
          + subnetwork         = "kubernetes"
          + subnetwork_project = (known after apply)

          + access_config {
              + nat_ip       = (known after apply)
              + network_tier = (known after apply)
            }
        }

      + scheduling {
          + automatic_restart   = (known after apply)
          + on_host_maintenance = (known after apply)
          + preemptible         = (known after apply)

          + node_affinities {
              + key      = (known after apply)
              + operator = (known after apply)
              + values   = (known after apply)
            }
        }

      + service_account {
          + email  = (known after apply)
          + scopes = [
              + "https://www.googleapis.com/auth/compute",
              + "https://www.googleapis.com/auth/devstorage.read_only",
              + "https://www.googleapis.com/auth/logging.write",
              + "https://www.googleapis.com/auth/monitoring",
              + "https://www.googleapis.com/auth/service.management.readonly",
              + "https://www.googleapis.com/auth/servicecontrol",
            ]
        }
    }

  # google_compute_instance.controller[1] will be created
  + resource "google_compute_instance" "controller" {
      + can_ip_forward       = true
      + cpu_platform         = (known after apply)
      + deletion_protection  = false
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + machine_type         = "n1-standard-1"
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "controller-1"
      + project              = (known after apply)
      + self_link            = (known after apply)
      + tags                 = [
          + "controller",
          + "kubernetes-the-hard-way",
        ]
      + tags_fingerprint     = (known after apply)
      + zone                 = "europe-west3-a"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + image  = "centos-cloud/centos-7-v20200309"
              + labels = (known after apply)
              + size   = 200
              + type   = (known after apply)
            }
        }

      + network_interface {
          + name               = (known after apply)
          + network            = (known after apply)
          + network_ip         = "10.240.0.11"
          + subnetwork         = "kubernetes"
          + subnetwork_project = (known after apply)

          + access_config {
              + nat_ip       = (known after apply)
              + network_tier = (known after apply)
            }
        }

      + scheduling {
          + automatic_restart   = (known after apply)
          + on_host_maintenance = (known after apply)
          + preemptible         = (known after apply)

          + node_affinities {
              + key      = (known after apply)
              + operator = (known after apply)
              + values   = (known after apply)
            }
        }

      + service_account {
          + email  = (known after apply)
          + scopes = [
              + "https://www.googleapis.com/auth/compute",
              + "https://www.googleapis.com/auth/devstorage.read_only",
              + "https://www.googleapis.com/auth/logging.write",
              + "https://www.googleapis.com/auth/monitoring",
              + "https://www.googleapis.com/auth/service.management.readonly",
              + "https://www.googleapis.com/auth/servicecontrol",
            ]
        }
    }

  # google_compute_instance.controller[2] will be created
  + resource "google_compute_instance" "controller" {
      + can_ip_forward       = true
      + cpu_platform         = (known after apply)
      + deletion_protection  = false
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + machine_type         = "n1-standard-1"
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "controller-2"
      + project              = (known after apply)
      + self_link            = (known after apply)
      + tags                 = [
          + "controller",
          + "kubernetes-the-hard-way",
        ]
      + tags_fingerprint     = (known after apply)
      + zone                 = "europe-west3-a"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + image  = "centos-cloud/centos-7-v20200309"
              + labels = (known after apply)
              + size   = 200
              + type   = (known after apply)
            }
        }

      + network_interface {
          + name               = (known after apply)
          + network            = (known after apply)
          + network_ip         = "10.240.0.12"
          + subnetwork         = "kubernetes"
          + subnetwork_project = (known after apply)

          + access_config {
              + nat_ip       = (known after apply)
              + network_tier = (known after apply)
            }
        }

      + scheduling {
          + automatic_restart   = (known after apply)
          + on_host_maintenance = (known after apply)
          + preemptible         = (known after apply)

          + node_affinities {
              + key      = (known after apply)
              + operator = (known after apply)
              + values   = (known after apply)
            }
        }

      + service_account {
          + email  = (known after apply)
          + scopes = [
              + "https://www.googleapis.com/auth/compute",
              + "https://www.googleapis.com/auth/devstorage.read_only",
              + "https://www.googleapis.com/auth/logging.write",
              + "https://www.googleapis.com/auth/monitoring",
              + "https://www.googleapis.com/auth/service.management.readonly",
              + "https://www.googleapis.com/auth/servicecontrol",
            ]
        }
    }

  # google_compute_instance.worker[0] will be created
  + resource "google_compute_instance" "worker" {
      + can_ip_forward       = true
      + cpu_platform         = (known after apply)
      + deletion_protection  = false
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + machine_type         = "n1-standard-1"
      + metadata             = {
          + "pod-cidr" = "10.200.0.0/24"
        }
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "worker-0"
      + project              = (known after apply)
      + self_link            = (known after apply)
      + tags                 = [
          + "kubernetes-the-hard-way",
          + "worker",
        ]
      + tags_fingerprint     = (known after apply)
      + zone                 = "europe-west3-a"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + image  = "centos-cloud/centos-7-v20200309"
              + labels = (known after apply)
              + size   = 200
              + type   = (known after apply)
            }
        }

      + network_interface {
          + name               = (known after apply)
          + network            = (known after apply)
          + network_ip         = "10.240.0.20"
          + subnetwork         = "kubernetes"
          + subnetwork_project = (known after apply)

          + access_config {
              + nat_ip       = (known after apply)
              + network_tier = (known after apply)
            }
        }

      + scheduling {
          + automatic_restart   = (known after apply)
          + on_host_maintenance = (known after apply)
          + preemptible         = (known after apply)

          + node_affinities {
              + key      = (known after apply)
              + operator = (known after apply)
              + values   = (known after apply)
            }
        }

      + service_account {
          + email  = (known after apply)
          + scopes = [
              + "https://www.googleapis.com/auth/compute",
              + "https://www.googleapis.com/auth/devstorage.read_only",
              + "https://www.googleapis.com/auth/logging.write",
              + "https://www.googleapis.com/auth/monitoring",
              + "https://www.googleapis.com/auth/service.management.readonly",
              + "https://www.googleapis.com/auth/servicecontrol",
            ]
        }
    }

  # google_compute_instance.worker[1] will be created
  + resource "google_compute_instance" "worker" {
      + can_ip_forward       = true
      + cpu_platform         = (known after apply)
      + deletion_protection  = false
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + machine_type         = "n1-standard-1"
      + metadata             = {
          + "pod-cidr" = "10.200.1.0/24"
        }
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "worker-1"
      + project              = (known after apply)
      + self_link            = (known after apply)
      + tags                 = [
          + "kubernetes-the-hard-way",
          + "worker",
        ]
      + tags_fingerprint     = (known after apply)
      + zone                 = "europe-west3-a"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + image  = "centos-cloud/centos-7-v20200309"
              + labels = (known after apply)
              + size   = 200
              + type   = (known after apply)
            }
        }

      + network_interface {
          + name               = (known after apply)
          + network            = (known after apply)
          + network_ip         = "10.240.0.21"
          + subnetwork         = "kubernetes"
          + subnetwork_project = (known after apply)

          + access_config {
              + nat_ip       = (known after apply)
              + network_tier = (known after apply)
            }
        }

      + scheduling {
          + automatic_restart   = (known after apply)
          + on_host_maintenance = (known after apply)
          + preemptible         = (known after apply)

          + node_affinities {
              + key      = (known after apply)
              + operator = (known after apply)
              + values   = (known after apply)
            }
        }

      + service_account {
          + email  = (known after apply)
          + scopes = [
              + "https://www.googleapis.com/auth/compute",
              + "https://www.googleapis.com/auth/devstorage.read_only",
              + "https://www.googleapis.com/auth/logging.write",
              + "https://www.googleapis.com/auth/monitoring",
              + "https://www.googleapis.com/auth/service.management.readonly",
              + "https://www.googleapis.com/auth/servicecontrol",
            ]
        }
    }

  # google_compute_instance.worker[2] will be created
  + resource "google_compute_instance" "worker" {
      + can_ip_forward       = true
      + cpu_platform         = (known after apply)
      + deletion_protection  = false
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + machine_type         = "n1-standard-1"
      + metadata             = {
          + "pod-cidr" = "10.200.2.0/24"
        }
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "worker-2"
      + project              = (known after apply)
      + self_link            = (known after apply)
      + tags                 = [
          + "kubernetes-the-hard-way",
          + "worker",
        ]
      + tags_fingerprint     = (known after apply)
      + zone                 = "europe-west3-a"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + image  = "centos-cloud/centos-7-v20200309"
              + labels = (known after apply)
              + size   = 200
              + type   = (known after apply)
            }
        }

      + network_interface {
          + name               = (known after apply)
          + network            = (known after apply)
          + network_ip         = "10.240.0.22"
          + subnetwork         = "kubernetes"
          + subnetwork_project = (known after apply)

          + access_config {
              + nat_ip       = (known after apply)
              + network_tier = (known after apply)
            }
        }

      + scheduling {
          + automatic_restart   = (known after apply)
          + on_host_maintenance = (known after apply)
          + preemptible         = (known after apply)

          + node_affinities {
              + key      = (known after apply)
              + operator = (known after apply)
              + values   = (known after apply)
            }
        }

      + service_account {
          + email  = (known after apply)
          + scopes = [
              + "https://www.googleapis.com/auth/compute",
              + "https://www.googleapis.com/auth/devstorage.read_only",
              + "https://www.googleapis.com/auth/logging.write",
              + "https://www.googleapis.com/auth/monitoring",
              + "https://www.googleapis.com/auth/service.management.readonly",
              + "https://www.googleapis.com/auth/servicecontrol",
            ]
        }
    }

  # google_compute_network.vpc_network will be created
  + resource "google_compute_network" "vpc_network" {
      + auto_create_subnetworks         = false
      + delete_default_routes_on_create = false
      + gateway_ipv4                    = (known after apply)
      + id                              = (known after apply)
      + ipv4_range                      = (known after apply)
      + name                            = "kubernetes-the-hard-way"
      + project                         = (known after apply)
      + routing_mode                    = (known after apply)
      + self_link                       = (known after apply)
    }

  # google_compute_route.default[0] will be created
  + resource "google_compute_route" "default" {
      + dest_range       = "10.200.0.0/24"
      + id               = (known after apply)
      + name             = "kubernetes-route-10-200-0-0-24"
      + network          = "kubernetes-the-hard-way"
      + next_hop_ip      = "10.240.0.20"
      + next_hop_network = (known after apply)
      + priority         = 1000
      + project          = (known after apply)
      + self_link        = (known after apply)
    }

  # google_compute_route.default[1] will be created
  + resource "google_compute_route" "default" {
      + dest_range       = "10.200.1.0/24"
      + id               = (known after apply)
      + name             = "kubernetes-route-10-200-1-0-24"
      + network          = "kubernetes-the-hard-way"
      + next_hop_ip      = "10.240.0.21"
      + next_hop_network = (known after apply)
      + priority         = 1000
      + project          = (known after apply)
      + self_link        = (known after apply)
    }

  # google_compute_route.default[2] will be created
  + resource "google_compute_route" "default" {
      + dest_range       = "10.200.2.0/24"
      + id               = (known after apply)
      + name             = "kubernetes-route-10-200-2-0-24"
      + network          = "kubernetes-the-hard-way"
      + next_hop_ip      = "10.240.0.22"
      + next_hop_network = (known after apply)
      + priority         = 1000
      + project          = (known after apply)
      + self_link        = (known after apply)
    }

  # google_compute_subnetwork.vpc_subnetwork will be created
  + resource "google_compute_subnetwork" "vpc_subnetwork" {
      + creation_timestamp = (known after apply)
      + enable_flow_logs   = (known after apply)
      + fingerprint        = (known after apply)
      + gateway_address    = (known after apply)
      + id                 = (known after apply)
      + ip_cidr_range      = "10.240.0.0/24"
      + name               = "kubernetes"
      + network            = (known after apply)
      + project            = (known after apply)
      + region             = "europe-west3"
      + secondary_ip_range = (known after apply)
      + self_link          = (known after apply)
    }

  # google_compute_target_pool.default will be created
  + resource "google_compute_target_pool" "default" {
      + health_checks    = [
          + "kubernetes",
        ]
      + id               = (known after apply)
      + instances        = [
          + "europe-west3-a/controller-0",
          + "europe-west3-a/controller-1",
          + "europe-west3-a/controller-2",
        ]
      + name             = "kubernetes-target-pool"
      + project          = (known after apply)
      + region           = (known after apply)
      + self_link        = (known after apply)
      + session_affinity = "NONE"
    }
