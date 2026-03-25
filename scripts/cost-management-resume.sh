#!/bin/bash
# Script to resume Azure resources before the hack
# Run this a few hours before the hack starts

RESOURCE_GROUP="contoso-traders-rgct325c"
AKS_CLUSTER="contoso-traders-aksct325c"
CARTS_ACA="contoso-traders-cartsct325c"

echo "🚀 Resuming services for the hack..."
echo ""

# 1. Scale AKS cluster back to 1 node
echo "📈 Scaling AKS cluster to 1 node..."
az aks scale \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_CLUSTER \
  --node-count 1 \
  --nodepool-name nodepool1
echo "✅ AKS scaled up (this may take 5-10 minutes)"
echo ""

# 2. Scale Container Apps back to 1-10 replicas
echo "📈 Scaling Container Apps..."
az containerapp update \
  --name $CARTS_ACA \
  --resource-group $RESOURCE_GROUP \
  --min-replicas 1 \
  --max-replicas 10
echo "✅ Container Apps scaled up"
echo ""

# 3. Resume SQL databases
echo "▶️  Resuming SQL databases..."
az sql db resume \
  --resource-group $RESOURCE_GROUP \
  --server contoso-traders-productsct325c \
  --name productsdb \
  2>/dev/null || echo "   Products DB: Already running"

az sql db resume \
  --resource-group $RESOURCE_GROUP \
  --server contoso-traders-profilesct325c \
  --name profilesdb \
  2>/dev/null || echo "   Profiles DB: Already running"

echo ""
echo "✅ All services resumed!"
echo ""
echo "⏱️  Allow 10-15 minutes for all services to be fully ready"
echo "🔗 Test the UI: https://contoso-traders-ui2ct325c-cjddh8g4evg7esgv.z03.azurefd.net/"
