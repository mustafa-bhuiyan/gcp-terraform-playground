resource "google_compute_instance" "testvm" {
  name                      = "test-vm"
  zone                      = "us-central1-a"
  machine_type              = "e2-small"
  allow_stopping_for_update = true

  tags = ["foo", "bar"]

  boot_disk {
    device_name = "testVM-boot-disk"
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "terraform-vm"
      }
    }
  }

  network_interface {
    // VPC network name
    network = "default"
    // access_config will provide an external ip for the vm 
    //so you can access the vm from outside networks ie. from internet or your local pc
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    "foo" = "bar"
  }

  metadata_startup_script = "echo hi!! > /test.txt"
}