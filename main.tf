#
# Terraform/Providers
#
terraform {
  required_version = ">= 0.11.0"
}

provider "triton" {
  version = ">= 0.4.1"
}

#
# Data sources
#
data "triton_datacenter" "current" {}

data "triton_account" "current" {}

#
# Locals
#
locals {
  machine_name_prefix = "${var.name}-kafka"
  kafka_address       = "${var.kafka_cns_service_name}.svc.${data.triton_account.current.id}.${data.triton_datacenter.current.name}.${var.cns_fqdn_base}"
}

#
# Machines
#
resource "triton_machine" "kafka" {
  count = "${var.machine_count}"

  name = "${var.name}-kafka-${count.index}"

  package = "${var.package}"
  image   = "${var.image}"

  firewall_enabled = true

  networks = ["${var.networks}"]

  cns {
    services = ["${var.kafka_cns_service_name}"]
  }

  metadata {
    kafka_confluent_version     = "${var.kafka_confluent_version}"
    kafka_connect_manta_version = "${var.kafka_connect_manta_version}"
    zookeeper_address           = "${var.zookeeper_address}"
  }
}

#
# Firewall Rules
#
resource "triton_firewall_rule" "ssh" {
  rule        = "FROM tag \"role\" = \"${var.bastion_role_tag}\" TO tag \"triton.cns.services\" = \"${var.kafka_cns_service_name}\" ALLOW tcp PORT 22"
  enabled     = true
  description = "${var.name} - Allow access from bastion hosts to Kafka servers."
}

resource "triton_firewall_rule" "kafka_client_access" {
  count = "${length(var.client_access)}"

  rule        = "FROM ${var.client_access[count.index]} TO tag \"triton.cns.services\" = \"${var.kafka_cns_service_name}\" ALLOW tcp PORT 9092"
  enabled     = true
  description = "${var.name} - Allow access from clients to Kafka servers."
}

resource "triton_firewall_rule" "kafka_to_kafka" {
  rule        = "FROM tag \"triton.cns.services\" = \"${var.kafka_cns_service_name}\" TO tag \"triton.cns.services\" = \"${var.kafka_cns_service_name}\" ALLOW tcp PORT 9092"
  enabled     = true
  description = "${var.name} - Allow access from Kafka servers to Kafka servers."
}
