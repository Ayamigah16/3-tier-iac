#!/bin/bash
set -euo pipefail

# Log everything
exec > >(tee /var/log/bastion-setup.log)
exec 2>&1

echo "=== Bastion Host Setup Started at $(date) ==="

# Update system
echo "Updating system packages..."
yum update -y

# Install useful tools
echo "Installing utilities..."
yum install -y \
  git \
  jq \
  vim \
  htop \
  nc \
  telnet \
  mysql \
  postgresql \
  docker \
  aws-cli

# Configure Docker
if command -v docker &> /dev/null; then
  echo "Configuring Docker..."
  systemctl start docker
  systemctl enable docker
  usermod -a -G docker ec2-user
fi

# Create welcome message
cat > /etc/motd << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║               ${project_name} Bastion Host                   ║
╚══════════════════════════════════════════════════════════════╝

This is a bastion/jump host for secure access to private resources.

Useful commands:
  - aws ec2 describe-instances        # List EC2 instances
  - docker ps                         # List Docker containers
  - mysql -h <host> -u <user> -p      # Connect to MySQL
  - psql -h <host> -U <user> -d <db>  # Connect to PostgreSQL

Security Notes:
  - Use SSH agent forwarding: ssh -A
  - Always use session logging
  - Minimize bastion access time

EOF

# Configure SSH
echo "Configuring SSH..."
cat >> /etc/ssh/sshd_config << 'EOF'

# Security hardening
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd yes
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

systemctl restart sshd

echo "=== Bastion Host Setup Completed at $(date) ==="
