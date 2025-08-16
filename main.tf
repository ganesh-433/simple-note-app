# Configure the Google Cloud provider
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = "project-demos-469216"
  region  = "us-central1"
  zone    = "us-central1-a"
  # You can use Application Default Credentials or a key file
  credentials = file("C:/Users/hr433/Downloads/project-demos-469216-6a14b6c85e02.json")
}

# Create a network and firewall rule
resource "google_compute_network" "vpc_network" {
  name = "terraform-vpc-network"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-ingress"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["80", "5000"]
  }
  source_ranges = ["0.0.0.0/0"]
}

# Define the GCE instance
resource "google_compute_instance" "app_vm" {
  name         = "notes-app-instance"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  # Use a public image
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      # This block allows an external IP
    }
  }

  # Startup script to install Docker and run the application
  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo usermod -aG docker $USER
    sudo docker run -d -p 5000:5000 ganesh243/notes-app:latest
  EOT
}

# Output the external IP address of the VM
output "instance_ip_address" {
  value = google_compute_instance.app_vm.network_interface[0].access_config[0].nat_ip
}