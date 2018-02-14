#!/bin/bash
#
# Installs Kafka with some customizations specific to the overall project.
#
# Note: Generally follows guidelines at https://web.arckafka.org/web/20170701145736/https://google.github.io/styleguide/shell.xml.
#

set -e

# check_prerequisites - exits if distro is not supported.
#
# Parameters:
#     None.
function check_prerequisites() {
  local distro
  if [[ -f "/etc/lsb-release" ]]; then
    distro="Ubuntu"
  fi

  if [[ -z "${distro}" ]]; then
    log "Unsupported platform. Exiting..."
    exit 1
  fi
}

# install_dependencies - installs dependencies
#
# Parameters:
#     -
function install_dependencies() {
  log "Updating package index..."
  apt-get -qq update
  log "Upgrading existing packages"
  apt-get -qq upgrade
  log "Installing prerequisites..."
  apt-get -qq --no-install-recommends install \
    wget openjdk-8-jdk

  log "Adding gophers repo..."
  add-apt-repository -y ppa:gophers/archive
  apt-get -qq update
  log "Installing sockaddr prerequisites..."
  apt-get -qq install \
    git golang-1.9
  log "Installing sockaddr..."
  GOPATH=/tmp/go /usr/lib/go-1.9/bin/go get -u github.com/hashicorp/go-sockaddr/cmd/sockaddr
  mv /tmp/go/bin/sockaddr /usr/local/sbin/
}

# check_arguments - exits if arguments are NOT satisfied
#
# Parameters:
#     $1: the version of kafka
#     $2: the version of kafka-connect-manta
#     $3: the zookeeper address
function check_arguments() {
  local -r kafka_confluent_version=${1}
  local -r kafka_connect_manta_version=${2}
  local -r zookeeper_address=${3}

  if [[ -z "${kafka_confluent_version}" ]]; then
    log "Kafka version NOT provided. Exiting..."
    exit 1
  fi

  if [[ -z "${kafka_connect_manta_version}" ]]; then
    log "kafka-connect-manta version NOT provided. Exiting..."
    exit 1
  fi

  if [[ -z "${zookeeper_address}" ]]; then
    log "Zookeeper Address NOT provided. Exiting..."
    exit 1
  fi
}

# install - downloads and installs the specified tool and version
#
# Parameters:
#     $1: the version of confluent kafka
#     $2: the version of kafka-connect-manta
#     $3: the zookeeper address
function install_kafka() {
  local -r kafka_confluent_version=${1}
  local -r kafka_connect_manta_version=${2}
  local -r zookeeper_address=${3}

  log "Installing Confluent Kafka ${kafka_confluent_version} public key..."
  wget -qO - "https://packages.confluent.io/deb/${kafka_confluent_version}/archive.key" | sudo apt-key add -

  log "Adding Confluent Kafka ${kafka_confluent_version} repository..."
  add-apt-repository "deb [arch=amd64] http://packages.confluent.io/deb/${kafka_confluent_version} stable main"

  log "Installing Confluent Kafka platform..."
  apt-get update
  apt-get -qq -y install confluent-platform-oss-2.11

  local -r address_ip_private=$(sockaddr eval GetPrivateIP)

  /usr/bin/printf "
advertised.listeners=PLAINTEXT://${address_ip_private}:9092
zookeeper.connect=${zookeeper_address}:2181
delete.topic.enable=true
log.dir=/var/lib/kafka
" > /etc/kafka/server.properties

  /usr/bin/printf "
[Unit]
Description=Kafka
Documentation=https://docs.confluent.io/current/quickstart.html
After=network-online.target
[Service]
Restart=on-failure
ExecStart=/usr/bin/kafka-server-start \
  /etc/kafka/server.properties
[Install]
WantedBy=default.target
" > /etc/systemd/system/kafka.service

  log "Starting Kafka..."
  systemctl daemon-reload

  systemctl enable kafka.service
  systemctl start kafka.service

  local -r path_file="kafka-connect-manta-${kafka_connect_manta_version}-jar-with-dependencies.jar"
  local -r path_install="/usr/share/java/kafka-connect-manta"

  log "Downloading kafka-connect-manta ${kafka_connect_manta_version}..."
  wget -O ${path_file} "https://github.com/joyent/kafka-connect-manta/releases/download/${kafka_connect_manta_version}/kafka-connect-manta-${kafka_connect_manta_version}-jar-with-dependencies.jar"

  log "Installing kafka-connect-manta ${kafka_connect_manta_version}..."
  mkdir "${path_install}"
  mv "${path_file}" "${path_install}"

}

# log - prints an informational message
#
# Parameters:
#     $1: the message
function log() {
  local -r message=${1}
  local -r script_name=$(basename ${0})
  echo -e "==> ${script_name}: ${message}"
}

# main
function main() {
  check_prerequisites

  local -r arg_kafka_confluent_version=$(mdata-get 'kafka_confluent_version')
  local -r arg_kafka_connect_manta_version=$(mdata-get 'kafka_connect_manta_version')
  local -r arg_zookeeper_address=$(mdata-get 'zookeeper_address')
  check_arguments \
    ${arg_kafka_confluent_version} ${arg_kafka_connect_manta_version} ${arg_zookeeper_address}

  install_dependencies
  install_kafka \
    ${arg_kafka_confluent_version} ${arg_kafka_connect_manta_version} ${arg_zookeeper_address}

  log "Done."
}

main
