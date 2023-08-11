# URL on which GitLab will be reachable
# It will be replaced automatically with a variable during instance provision
external_url ''

# Repository storage paths
git_data_dirs({
 "default" => { "path" => "${repositories_storage_path}" }
})

# GitLab Configuration
gitlab_rails['db_adapter'] = "postgresql"
gitlab_rails['db_encoding'] = "unicode"
gitlab_rails['db_host'] = "${db_host}"
gitlab_rails['db_database'] = "${db_name}"
gitlab_rails['db_username'] = "${db_username}"
gitlab_rails['db_password'] = "${db_password}"
gitlab_rails['lfs_enabled'] = true
gitlab_rails['lfs_storage_path'] = "${lfs_storage_path}"
gitlab_rails['gitlab_ssh_host'] = "${gitlab_ssh_clone_endpoint}"
gitlab_rails['gitlab_shell_ssh_port'] = 22

# GitLab SMTP Configuration
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp-relay.gmail.com"
gitlab_rails['smtp_port'] = 587
gitlab_rails['smtp_user_name'] = "${smtp_username}"
gitlab_rails['smtp_password'] = "${smtp_password}"
gitlab_rails['smtp_domain'] = "smtp-relay.gmail.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = false
gitlab_rails['gitlab_email_from'] = "${gitlab_email_from}"
gitlab_rails['gitlab_email_reply_to'] = "${gitlab_email_reply_to}"

# GitLab PostgreSQL Configuration
postgresql['enable'] = false

# Redis Configuration
redis['enable'] = false
gitlab_rails['redis_host'] = "${redis_host}"
gitlab_rails['redis_port'] = 6379

# GitLab Nginx Configuration
nginx['listen_port'] = 80 # ALB will forward incoming requests to this port
nginx['listen_https'] = false # GitLab won't handle SSL, so this remains false
# Set the proxy headers to indicate that the connection is over HTTP and SSL is off.
# This ensures that GitLab processes the requests correctly.
nginx['proxy_set_headers'] = {
  "X-Forwarded-Proto" => "https",
  "X-Forwarded-Ssl" => "on"
}

# GitLab Registry Configuration
registry['enable'] = false

# Let's Configuration
# letsencrypt['enable'] = true
# letsencrypt['auto_renew'] = true

# Renew certificate every 7th day at 12:30
# letsencrypt['auto_renew_hour'] = "12"
# letsencrypt['auto_renew_minute'] = "30"
# letsencrypt['auto_renew_day_of_month'] = "*/7"

# GitLab Locally-mounted Backup Configuration
gitlab_rails['backup_path'] = ''
gitlab_rails['backup_archive_permissions'] = 0644

# Limit backup lifetime to 7 days - 604800 seconds
gitlab_rails['backup_keep_time'] = 604800

# Sign-up Configuration
gitlab_rails['gitlab_signup_enabled'] = false

# Microsoft OAuth Configuration
gitlab_rails['omniauth_allow_single_sign_on'] = true
gitlab_rails['omniauth_block_auto_created_users'] = false
gitlab_rails['omniauth_allow_bypass_two_factor'] = ["azure_activedirectory_v2"]
gitlab_rails['omniauth_auto_link_user'] = ["azure_activedirectory_v2"]

gitlab_rails['omniauth_providers'] = [
  {
    "name" => "azure_activedirectory_v2",
    "label" => "Microsoft Azure AD",
    "args" => {
      "client_id" => "${azure_oauth2_client_id}",
      "client_secret" => "${azure_oauth2_client_secret}",
      "tenant_id" => "${azure_oauth2_tenant_id}",
    }
  }
]
