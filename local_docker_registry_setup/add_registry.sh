#!/bin/bash

REGISTRY_DOMAIN="registry.mycompany.dev"
REGISTRY_IP="192.168.56.101"   
CERT_FILE="./domain.crt" 

echo "Adding $REGISTRY_DOMAIN to /etc/hosts..."
if ! grep -q "$REGISTRY_DOMAIN" /etc/hosts; then
  echo "$REGISTRY_IP  $REGISTRY_DOMAIN" | sudo tee -a /etc/hosts
else
  echo " Already present in /etc/hosts."
fi

echo "Setting up Docker certs for $REGISTRY_DOMAIN..."
sudo mkdir -p /etc/docker/certs.d/$REGISTRY_DOMAIN
sudo cp "$CERT_FILE" /etc/docker/certs.d/$REGISTRY_DOMAIN/ca.crt

echo "Restarting Docker..."
sudo systemctl restart docker

echo "Now logging in to the registry..."
docker login $REGISTRY_DOMAIN

echo ""
echo "Done! You can now tag and push images like this:"
echo "docker tag alpine $REGISTRY_DOMAIN/alpine"
echo "docker push $REGISTRY_DOMAIN/alpine"
