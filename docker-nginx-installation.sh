#!/bin/bash
sudo yum update -y && sudo yum install -y docker
sudo usermod -aG docker ec2-user
newgrp docker
sudo systemctl start docker
sudo systemctl enable docker
docker run -d -p 80:80 nginx