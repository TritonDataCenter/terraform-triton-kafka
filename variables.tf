#
# Variables
#
variable "name" {
  description = "The name of the environment."
  type        = "string"
}

variable "image" {
  description = "The image to deploy as the Kafka machine(s)."
  type        = "string"
}

variable "package" {
  description = "The package to deploy as the Kafka machine(s)."
  type        = "string"
}

variable "networks" {
  description = "The networks to deploy the Kafka machine(s) within."
  type        = "list"
}

variable "private_key_path" {
  description = "The path to the private key to use for provisioning machines."
  type        = "string"
}

variable "user" {
  description = "The user to use for provisioning machines."
  type        = "string"
  default     = "root"
}

variable "provision" {
  description = "Boolean 'switch' to indicate if Terraform should do the machine provisioning to install and configure Kafka."
  type        = "string"
}

variable "kafka_confluent_version" {
  description = "The version of Kafka Confluent to install. See https://docs.confluent.io/current/."
  type        = "string"
  default     = "4.0"
}

variable "kafka_connect_manta_version" {
  description = "The version of Kafka Connect Manta to install. See https://github.com/joyent/kafka-connect-manta/releases."
  type        = "string"
  default     = "1.0.0-SNAPSHOT"
}

variable "machine_count" {
  description = "The number of Kafka machines to provision."
  type        = "string"
  default     = "3"
}

variable "kafka_cns_service_name" {
  description = "The kafka CNS service name. Note: this is the service name only, not the full CNS record."
  type        = "string"
  default     = "kafka"
}

variable "client_access" {
  description = <<EOF
'From' targets to allow client access to Kafka's client port(s) - i.e. access from other VMs or public internet.
See https://docs.joyent.com/public-cloud/network/firewall/cloud-firewall-rules-reference#target
for target syntax.
EOF

  type    = "list"
  default = ["any"]
}

variable "zookeeper_address" {
  description = "The address to the Zookeeper cluster."
  type        = "string"
}

variable "cns_fqdn_base" {
  description = "The fully qualified domain name base for the CNS address - e.g. 'cns.joyent.com' for Joyent Public Cloud."
  type        = "string"
  default     = "cns.joyent.com"
}

variable "bastion_host" {
  description = "The Bastion host to use for provisioning."
  type        = "string"
}

variable "bastion_user" {
  description = "The Bastion user to use for provisioning."
  type        = "string"
}

variable "bastion_role_tag" {
  description = "The 'role' tag for the Kafka machine(s) to allow access FROM the Bastion machine(s)."
  type        = "string"
}
