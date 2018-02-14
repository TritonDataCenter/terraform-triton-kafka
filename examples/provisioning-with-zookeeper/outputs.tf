#
# Outputs
#
output "bastion_ip" {
  value = ["${module.bastion.bastion_ip}"]
}

output "kafka_ip" {
  value = ["${module.kafka.kafka_ip}"]
}

output "kafka_address" {
  value = ["${module.kafka.kafka_address}"]
}
