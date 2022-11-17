#!/bin/sh

echo "This script will create or destroy docker builder server in the Hetzner Cloud."
echo "Make sure you have created 'secrets.auto.tfvars' file with your token!"
echo ""
echo "Choose an option:"
echo "1. Create builder server"
echo "2. Destroy builder server"
echo "3. Exit"
echo ""

echo "Enter your choice: "
read -r action

case $action in
  1)
    # Create builder server
    echo "Creating builder server..."
    terraform init
    touch output.tmp
    terraform apply -auto-approve > output.tmp
    echo "Docker builder server created with IP: $server_url"
    # Get url from Terraform output
    server_url=$(cat output.tmp | sed -n 's/.*"docker-builder" = //p' | sed -r "s/\\\"//g")
    # Save url to ENV
    export DOCKER_HOST="ssh://root@$server_url"
    echo "DOCKER_HOST updated with new server url."
    # Remove tmp file
    rm output.tmp
    echo "Tap this to reconnect in another shell:"
    echo "export DOCKER_HOST=\"ssh://root@$server_url\""
    echo "Creating docker builder completed."
    return
    ;;
  2)
    # Destroy builder server
    echo "Destroying builder server..."
    unset DOCKER_HOST
    terraform destroy -auto-approve
    echo "Docker builder server destroyed."
    return
    ;;
  3)
    return
    ;;
  *)
    echo "unknown option"
    return
    ;;
esac
