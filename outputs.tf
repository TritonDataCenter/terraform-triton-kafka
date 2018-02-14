#
# Outputs
#
output "kafka_ip" {
  value = ["${triton_machine.kafka.*.primaryip}"]
}

output "kafka_cns_service_name" {
  value = "${var.kafka_cns_service_name}"
}

output "kafka_address" {
  value = "${local.kafka_address}"
}
