resource "null_resource" "kafka_install" {
  count = "${var.provision == "true" ? var.machine_count : 0}"

  triggers {
    machine_ids = "${triton_machine.kafka.*.id[count.index]}"
  }

  connection {
    bastion_host        = "${var.bastion_host}"
    bastion_user        = "${var.bastion_user}"
    bastion_private_key = "${file(var.private_key_path)}"

    host        = "${triton_machine.kafka.*.primaryip[count.index]}"
    user        = "${var.user}"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/kafka_installer/",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/packer/scripts/install_kafka.sh"
    destination = "/tmp/kafka_installer/install_kafka.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0755 /tmp/kafka_installer/install_kafka.sh",
      "sudo /tmp/kafka_installer/install_kafka.sh",
    ]
  }

  # clean up
  provisioner "remote-exec" {
    inline = [
      "rm -rf /tmp/kafka_installer/",
    ]
  }
}
