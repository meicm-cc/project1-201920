provider "google" {
  credentials = file(var.credentials_path)
  project = var.project_name
  region = var.region
}

resource "google_compute_firewall" "allow-http" {
  name    = "fw-allow-http"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80","443"]
  }
  target_tags = ["http"] 
}
resource "google_compute_firewall" "allow-ssh" {
  name    = "fw-allow-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh"]
}


resource "google_compute_instance" "node" {
  name = "node"
  machine_type = var.machine_type
  zone = var.zone
  tags = ["ssh","http"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
  metadata = {
    ssh-keys = "${var.user}:${file(var.public_key_path)}"
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }
}

output "ip" {
  value = google_compute_instance.node.network_interface.0.access_config.0.nat_ip
}