#!/bin/bash
# Script to minimize Azure costs by scaling down resources
# Run this to shut down expensive compute resources

RESOURCE_GROUP="contoso-traders-rgct325c"
AKS_CLUSTER="contoso-traders-aksct325c"
CARTS_ACA="contoso-traders-cartsct325c"

echo "🛑 Shutting down expensive resources to minimize costs..."
echo ""

# 1. Scale AKS cluster to 0 nodes (BIGGEST COST SAVER)
echo "📉 Scaling AKS cluster to 0 nodes..."
az aks scale \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_CLUSTER \
  --node-count 0 \
  --nodepool-name nodepool1
echo "✅ AKS scaled down"
echo ""

# 2. Scale Container Apps to 0 replicas
echo "📉 Scaling Container Apps to 0 replicas..."
az containerapp update \
  --name $CARTS_ACA \
  --resource-group $RESOURCE_GROUP \
  --min-replicas 0 \
  --max-replicas 0
echo "✅ Container Apps scaled down"
echo ""

# 3. Pause SQL databases (optional - reduces costs further)
echo "⏸️  Pausing SQL databases..."
az sql db pause \
  --resource-group $RESOURCE_GROUP \
  --server contoso-traders-productsct325c \
  --name productsdb \
  2>/dev/null || echo "   Products DB: Already paused or does not support pause"

az sql db pause \
  --resource-group $RESOURCE_GROUP \
  --server contoso-traders-profilesct325c \
  --name profilesdb \
  2>/dev/null || echo "   Profiles DB: Already paused or does not support pause"

echo ""
echo "✅ Cost optimization complete!"
echo ""
echo "💵 Estimated monthly savings: ~$150-300/month"
echo ""
echo "To resume services before the hack, run: ./scripts/cost-management-resume.sh"
