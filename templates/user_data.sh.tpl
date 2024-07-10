#!/bin/bash

# Create a directory to store the error log for the script
mkdir -p /var/log/user_data_script

# Redirect any error of the script to the output to the error log
exec 2>/var/log/user_data_script/errors.log

# Note AWS Nitro System-based instances (like C5, M5, R5, T3, and newer instance types) attach EBS volumes
# as NVMe block devices, which have a different naming convention compared to the traditional block device names.
# For instances that use the Xen hypervisor (including many earlier generation instance types),
# device names are in the format of /dev/xvdf through /dev/xvdp.
# For instances that use the Nitro hypervisor (including many newer generation instance types),
# device names are in the format of /dev/nvme1n1 through /dev/nvme26n1.

# This loop continues until the EBS volume is attached to the instance
# The instance checks for the existence of the  volume every 5 seconds
while [ ! -e "${ebs_volume_1_name}" ]; do
  echo "Waiting for "${ebs_volume_1_name}" to be attached"
  sleep 5
done

# Check if the EBS volume needs formatting
if ! file -s "${ebs_volume_1_name}" | grep -q filesystem; then
  sudo mkfs -t ext4 "${ebs_volume_1_name}"
fi

# Create the mount point directory
sudo mkdir -p "${ebs_volume_1_mount_point}"

# Mount the EBS volume
sudo mount "${ebs_volume_1_name}" "${ebs_volume_1_mount_point}"

# Configure automatic mount on reboot
echo "${ebs_volume_1_name} ${ebs_volume_1_mount_point} ext4 defaults,nofail 0 0" | sudo tee -a /etc/fstab > /dev/null

# This loop continues until the EBS volume is attached to the instance
# The instance checks for the existence of the  volume every 5 seconds
while [ ! -e "${ebs_volume_1_name}" ]; do
  echo "Waiting for "${ebs_volume_1_name}" to be attached"
  sleep 5
done

# Check if the EBS volume needs formatting
if ! file -s "${backup_ebs_volume_1_name}" | grep -q filesystem; then
  sudo mkfs -t ext4 "${backup_ebs_volume_1_name}"
fi

# Create the mount point directory
sudo mkdir -p "${backup_ebs_volume_1_mount_point}"

# Mount the EBS volume
sudo mount "${backup_ebs_volume_1_name}" "${backup_ebs_volume_1_mount_point}"

# Configure automatic mount on reboot
echo "${backup_ebs_volume_1_name} ${backup_ebs_volume_1_mount_point} ext4 defaults,nofail 0 0" | sudo tee -a /etc/fstab > /dev/null

# Create directories if it does not exist yet on a separate EBS volume
sudo mkdir -p "${ebs_volume_1_mount_point}/lfs-objects"
sudo mkdir -p "${ebs_volume_1_mount_point}/secrets"
sudo mkdir -p "${ebs_volume_1_mount_point}/backups"
sudo mkdir -p "${backup_ebs_volume_1_mount_point}/gitlab"

# Set the DEBIAN_FRONTEND environment variable
export DEBIAN_FRONTEND=noninteractive

# Pre-answer postfix configuration questions
echo "postfix postfix/mailname string '${gitlab_mail_domain_install}'" | sudo debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | sudo debconf-set-selections

# Update the package lists for upgrades and new package installations
sudo apt-get update

# Install necessary packages. This includes "curl" for downloading data from URLs, "openssh-server" for secure shell into the system,
# "ca-certificates" for secure web communication, "tzdata" for time zone data, "perl" a programming language, and "postfix" a mail transfer agent
sudo apt-get install -y curl openssh-server ca-certificates tzdata perl postfix

# Download the GitLab repository installation script from the GitLab package server and execute it with bash. This adds the GitLab package
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash

# Set the EXTERNAL_URL environment variable to the external URL of the GitLab instance and install the GitLab Community Edition package.
# The external URL is used by GitLab for various features such as links in emails.
sudo EXTERNAL_URL="${gitlab_external_url_install}" apt install -y gitlab-ce

# Use the -f option with apt-get install to attempt to correct a system with broken dependencies in place.
# This option, when used with install/remove, can omit any packages to permit APT to deduce a likely solution.
sudo apt-get install -f

# Stop GitLab services
sudo gitlab-ctl stop

# Write the rendered GitLab configuration to the gitlab.rb file
cat <<EOF > /etc/gitlab/gitlab.rb
${gitlab_config_file}
EOF

# Set external url for GitLab
sudo sed -i "s|external_url.*|external_url '${gitlab_external_url_install}'|" /etc/gitlab/gitlab.rb

# Set database host for GitLab
sudo sed -i "/^gitlab_rails\['db_host'\]/s/:5432//g" /etc/gitlab/gitlab.rb

# Set path for GitLab Backups
sudo sed -i "s|gitlab_rails\['backup_path'\].*|gitlab_rails\['backup_path'\] = '${gitlab_backup_ebs_volume_1_mount_point}'|" /etc/gitlab/gitlab.rb

# Backup secrets file if it does not exist yet on a separate EBS volume
if [ -f "${ebs_volume_1_mount_point}/secrets/gitlab-secrets.json" ]; then
    timestamp=$(date +%Y%m%d%H%M%S)
    sudo cp "${ebs_volume_1_mount_point}/secrets/gitlab-secrets.json" "${ebs_volume_1_mount_point}/backups/gitlab-secrets.json.${timestamp}"
    echo "Backup created at ${ebs_volume_1_mount_point}/backups/gitlab-secrets.json.${timestamp}"
else
    echo "File to be backed up does not exist."
fi

# Move the original secrets file if it does not exist yet on a separate EBS volume
if [ -f "/etc/gitlab/gitlab-secrets.json" ]; then
    if [ ! -f "${ebs_volume_1_mount_point}/secrets/gitlab-secrets.json" ]; then
        sudo mv "/etc/gitlab/gitlab-secrets.json" "${ebs_volume_1_mount_point}/secrets/gitlab-secrets.json"
        echo "File moved."
    else
        echo "Destination file already exists. File not moved."
    fi
else
    echo "Source file does not exist."
fi

# Define cron file
CRON_FILE="/tmp/gitlab_backup_cron"

# Check if the cron job already exists
if [ -f "$CRON_FILE" ]; then
  grep -q "/opt/gitlab/bin/gitlab-backup create CRON=1" "$CRON_FILE"
  if [[ $? -eq 0 ]]; then
    echo "Cron job already exists."
  else
    echo "Adding cron job..."
    # Echo new cron into cron file
    echo "0 2 * * * /opt/gitlab/bin/gitlab-backup create CRON=1" >> "$CRON_FILE"
  fi
else
  echo "Adding cron job..."
  # Echo new cron into cron file
  echo "0 2 * * * /opt/gitlab/bin/gitlab-backup create CRON=1" > "$CRON_FILE"
fi

# Install new cron file
crontab "$CRON_FILE"

# Remove temporary cron file
rm "$CRON_FILE"

# Create a symbolic links
sudo ln -s "${ebs_volume_1_mount_point}/secrets/gitlab-secrets.json" /etc/gitlab/gitlab-secrets.json

# Set permissions for the GitLab data
sudo chown -R git:git "${ebs_volume_1_mount_point}/lfs-objects"
sudo chown -R git:git "${ebs_volume_1_mount_point}/secrets"
sudo chown -R git:git "${backup_ebs_volume_1_mount_point}/gitlab"

sudo chmod -R 700 "${ebs_volume_1_mount_point}/lfs-objects"
sudo chmod -R 600 "${ebs_volume_1_mount_point}/secrets"
sudo chmod -R 644 "${backup_ebs_volume_1_mount_point}/gitlab"

# Install the required extensions for PostgreSQL
DB_PASSWORD=${db_password_install}
RDS_ENDPOINT_NO_PORT=$(echo ${db_host_install} | sed 's/:5432//')
sudo PGPASSWORD=$DB_PASSWORD /opt/gitlab/embedded/bin/psql -U gitlab -h $RDS_ENDPOINT_NO_PORT -d gitlabhq_production <<EOF
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gist;
EOF

# Reconfigure GitLab to apply the changes
sudo gitlab-ctl reconfigure

# Start GitLab services
sudo gitlab-ctl start
