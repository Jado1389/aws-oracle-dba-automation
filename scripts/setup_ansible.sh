#!/bin/bash
set -e

export AWS_PROFILE=terraform-admin

PROJECT_DIR="$HOME/aws-oracle-dba-automation"
ANSIBLE_BIN="$PROJECT_DIR/tools/ansible-venv/bin"

if [ ! -x "$ANSIBLE_BIN/ansible" ]; then
    echo "Ansible virtual environment is missing."
    echo "Rebuild it before continuing."
    exit 1
fi

export PATH="$ANSIBLE_BIN:$PATH"

echo "AWS identity:"
aws sts get-caller-identity

echo
echo "Ansible version:"
ansible --version

echo
echo "Ansible setup complete."
