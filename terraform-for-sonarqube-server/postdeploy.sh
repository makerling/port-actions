#!/bin/bash

# start logging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# command-line arguments from terraform
SQ_VERSION="${1}" # 2025.1.0.102418

# Update and install prerequisites
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk wget unzip ca-certificates curl

# Set system prerequisites
sudo sh -c 'echo "vm.max_map_count=262144" >> /etc/sysctl.conf'
sudo sh -c 'echo "fs.file-max=131072" >> /etc/sysctl.conf'
sudo sysctl -p
echo "sysctl.conf file:"
cat /etc/sysctl.conf

# # Set user limits for SonarQube
# echo "${var.admin_username} soft nofile 131072" | sudo tee -a /etc/security/limits.conf
# echo "${var.admin_username} hard nofile 131072" | sudo tee -a /etc/security/limits.conf
# echo "${var.admin_username} soft nproc 8192" | sudo tee -a /etc/security/limits.conf
# echo "${var.admin_username} hard nproc 8192" | sudo tee -a /etc/security/limits.conf

# echo "${var.sonarqube_version}"
# echo "testing: \$\{sonarqube_version\}: "
# echo "${sonarqube_version}

# Download and install SonarQube            
echo "downloading SonarQube:"
wget https://binaries.sonarsource.com/CommercialDistribution/sonarqube-enterprise/sonarqube-enterprise-${SQ_VERSION}.zip
unzip sonarqube-enterprise-${SQ_VERSION}.zip
sudo mv sonarqube-${SQ_VERSION} /opt/sonarqube

sudo groupadd sonar
sudo useradd -d /opt/sonarqube -g sonar sonar
sudo chown -R sonar:sonar /opt/sonarqube

echo "creating systemd service for SonarQube:"
echo "[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=simple
User=sonar
Group=sonar
PermissionsStartOnly=true
ExecStart=/bin/nohup /usr/bin/java -Xms32m -Xmx32m -Djava.net.preferIPv4Stack=true -jar /opt/sonarqube/lib/sonar-application-2025.1.0.102418.jar
StandardOutput=journal
LimitNOFILE=131072
LimitNPROC=8192
TimeoutStartSec=5
Restart=always
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/sonarqube.service

echo "Contents of SonarQube service file:"
cat /etc/systemd/system/sonarqube.service

# Start SonarQube service
sudo systemctl enable sonarqube
sudo systemctl start sonarqube
sudo systemctl status sonarqube