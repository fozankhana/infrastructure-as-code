#!/bin/bash
set -euo pipefail

# -------------------------------------------------------------------
# Bootstrap script — runs once on first instance launch
# Variables are injected by Terraform templatefile()
# -------------------------------------------------------------------

APP_VERSION="${app_version}"
ENVIRONMENT="${environment}"
DB_HOST="${db_host}"

# Write environment config for the application
cat > /etc/app.env <<EOF
APP_VERSION=$${APP_VERSION}
ENVIRONMENT=$${ENVIRONMENT}
DB_HOST=$${DB_HOST}
DB_PORT=5432
EOF

# Install SSM agent (included in AL2023 but ensure it's running)
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# -------------------------------------------------------------------
# Replace the block below with your actual application install steps
# -------------------------------------------------------------------
# Example:
#   aws s3 cp s3://my-artifacts/app-$${APP_VERSION}.tar.gz /opt/app.tar.gz
#   tar -xzf /opt/app.tar.gz -C /opt/app
#   systemctl enable app && systemctl start app
# -------------------------------------------------------------------

echo "Bootstrap complete — version=$${APP_VERSION} env=$${ENVIRONMENT}"
