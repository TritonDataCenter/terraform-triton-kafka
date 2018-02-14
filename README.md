# Triton Kafka Terraform Module

A Terraform module to create a [Kafka](https://kafka.apache.org/) cluster integrated with Manta using 
[Kafka Connect Sink Connector for Joyent Manta](https://github.com/joyent/kafka-connect-manta). Uses Confluent's 
Kafka distribution.

## Usage

```hcl
data "triton_image" "ubuntu" {
  name        = "ubuntu-16.04"
  type        = "lx-dataset"
  most_recent = true
}

data "triton_network" "public" {
  name = "Joyent-SDC-Public"
}

data "triton_network" "private" {
  name = "My-Fabric-Network"
}

module "bastion" {
  source = "github.com/joyent/terraform-triton-bastion"

  name    = "kafka-basic-with-provisioning"
  image   = "${data.triton_image.ubuntu.id}"
  package = "g4-general-4G"

  networks = [
    "${data.triton_network.public.id}",
    "${data.triton_network.private.id}",
  ]
}

module "kafka" {
  source = "github.com/joyent/terraform-triton-kafka"

  name    = "kafka-basic-with-provisioning"
  image   = "${data.triton_image.ubuntu.id}"
  package = "g4-general-4G"

  networks = [
    "${data.triton_network.private.id}",
  ]

  provision        = "true"
  private_key_path = "${var.private_key_path}"

  client_access = ["any"]

  zookeeper_address = "${var.zookeeper_address}"

  bastion_host     = "${element(module.bastion.bastion_ip,0)}"
  bastion_user     = "${module.bastion.bastion_user}"
  bastion_role_tag = "${module.bastion.bastion_role_tag}"
}
```

## Examples
- [basic-with-provisioning](examples/provisioning-with-zookeeper) - Deploys a Kafka cluster. Kafka machine(s) 
will be _provisioned_ by Terraform.
  - _Note: This method with Terraform provisioning is only recommended for prototyping and light testing._

## Resources created

- [`triton_machine.kafka`](https://www.terraform.io/docs/providers/triton/r/triton_machine.html): The Kafka cluster 
machine(s). 
- [`triton_firewall_rule.ssh`](https://www.terraform.io/docs/providers/triton/r/triton_firewall_rule.html): The firewall
rule(s) allowing SSH access FROM the bastion machine(s) TO the Kafka machine.
- [`triton_firewall_rule.kafka_client_access`](https://www.terraform.io/docs/providers/triton/r/triton_firewall_rule.html): The 
firewall rule(s) allowing access FROM client machines TO Kafka client ports.
- [`triton_firewall_rule.kafka_to_kafka`](https://www.terraform.io/docs/providers/triton/r/triton_firewall_rule.html): The 
firewall rule(s) allowing access FROM Kafka machines TO Kafka machines.
