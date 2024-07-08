# az login
# az account set --subscription "0557bba5-5cab-4a81-9c29-bd557b67a8e2"

# Set variables
resourceGroupName="vm-peer-hub-test"
location="northeurope"

# Delete RG
# az group delete --resource-group $resourceGroupName

# VNet 1 - same address
vnet1Name="sameAddressVNet"
vnet1AddressPrefix="10.0.0.0/16"
subnet1Name="subnet1"
subnet1Prefix="10.0.1.0/24"

# VNet 2 - new address
vnet2Name="newAddressVNet"
vnet2AddressPrefix="10.1.0.0/16"

# VNet 3 - hub
hubVnetName="hubVNet"
hubVnetAddressPrefix="10.2.0.0/16"
hubSubnetName="GatewaySubnet"
hubSubnetPrefix="10.2.0.0/24"
firewallSubnetName="AzureFirewallSubnet"
firewallSubnetPrefix="10.2.1.0/24"

# Peerings
vnet1ToVnet2Peering="vnet1ToVnet2"
vnet2ToVnet1Peering="vnet2ToVnet1"
vnet2ToHubPeering="vnet2ToHub"
hubToVnet2Peering="hubToVnet2"
vnet1ToHubPeering="vnet1ToHub"
hubToVnet1Peering="hubToVnet1"

# Route table
routeTableName="myRouteTable"

# VM
vmName="myVM"
vmSize="Standard_B1s"
adminUsername="azureuser"
adminPassword="P@ssw0rd12345"  # Make sure to meet complexity requirements

# Firewall
firewallName="myFirewall"
firewallPublicIpName="myFirewallPublicIP"
firewallRouteTableName="firewallRouteTable"

# Create Resource Group
az group create --name $resourceGroupName --location $location

# Create VNet 1 with a subnet
az network vnet create \
    --resource-group $resourceGroupName \
    --name $vnet1Name \
    --address-prefix $vnet1AddressPrefix \
    --location $location \
    --subnet-name $subnet1Name \
    --subnet-prefix $subnet1Prefix

# Create VNet 2
az network vnet create \
    --resource-group $resourceGroupName \
    --name $vnet2Name \
    --address-prefix $vnet2AddressPrefix \
    --location $location

# Create Hub VNet with GatewaySubnet and AzureFirewallSubnet
az network vnet create \
    --resource-group $resourceGroupName \
    --name $hubVnetName \
    --address-prefix $hubVnetAddressPrefix \
    --location $location

az network vnet subnet create \
    --resource-group $resourceGroupName \
    --vnet-name $hubVnetName \
    --name $hubSubnetName \
    --address-prefix $hubSubnetPrefix

az network vnet subnet create \
    --resource-group $resourceGroupName \
    --vnet-name $hubVnetName \
    --name $firewallSubnetName \
    --address-prefix $firewallSubnetPrefix

# Create a route table
az network route-table create \
    --resource-group $resourceGroupName \
    --name $routeTableName \
    --location $location

# Create a route in the route table to force traffic through the Azure Firewall
az network route-table route create \
    --resource-group $resourceGroupName \
    --route-table-name $routeTableName \
    --name "routeToFirewall" \
    --address-prefix "0.0.0.0/0" \
    --next-hop-type "VirtualAppliance" \
    --next-hop-ip-address "10.2.1.4"  # This will be the IP address of the firewall in the AzureFirewallSubnet

# Associate the route table with the subnet of VNet 1
az network vnet subnet update \
    --resource-group $resourceGroupName \
    --vnet-name $vnet1Name \
    --name $subnet1Name \
    --route-table $routeTableName

# Peer VNet 1 to VNet 2
az network vnet peering create \
    --resource-group $resourceGroupName \
    --vnet-name $vnet1Name \
    --name $vnet1ToVnet2Peering \
    --remote-vnet $vnet2Name \
    --allow-vnet-access

az network vnet peering create \
    --resource-group $resourceGroupName \
    --vnet-name $vnet2Name \
    --name $vnet2ToVnet1Peering \
    --remote-vnet $vnet1Name \
    --allow-vnet-access

# Peer VNet 2 to Hub VNet
az network vnet peering create \
    --resource-group $resourceGroupName \
    --vnet-name $vnet2Name \
    --name $vnet2ToHubPeering \
    --remote-vnet $hubVnetName \
    --allow-vnet-access

az network vnet peering create \
    --resource-group $resourceGroupName \
    --vnet-name $hubVnetName \
    --name $hubToVnet2Peering \
    --remote-vnet $vnet2Name \
    --allow-vnet-access

# Peer VNet 1 to Hub VNet (for forcing traffic through the hub)
az network vnet peering create \
    --resource-group $resourceGroupName \
    --vnet-name $vnet1Name \
    --name $vnet1ToHubPeering \
    --remote-vnet $hubVnetName \
    --allow-vnet-access \
    --allow-forwarded-traffic \
    --allow-gateway-transit

az network vnet peering create \
    --resource-group $resourceGroupName \
    --vnet-name $hubVnetName \
    --name $hubToVnet1Peering \
    --remote-vnet $vnet1Name \
    --allow-vnet-access \
    --use-remote-gateways

# Create Public IP for the firewall
az network public-ip create \
    --resource-group $resourceGroupName \
    --name $firewallPublicIpName \
    --sku "Standard" \
    --location $location

# Create the Azure Firewall
az network firewall create \
    --resource-group $resourceGroupName \
    --name $firewallName \
    --location $location \
    -- sku "Basic"

# Configure the firewall IP configuration
az network firewall ip-config create \
    --resource-group $resourceGroupName \
    --firewall-name $firewallName \
    --name "firewallConfig" \
    --public-ip-address $firewallPublicIpName \
    --vnet-name $hubVnetName

# Update the route table with the firewall's private IP
firewallPrivateIp=$(az network firewall show \
    --resource-group $resourceGroupName \
    --name $firewallName \
    --query "ipConfigurations[0].privateIpAddress" \
    --output tsv)

az network route-table route update \
    --resource-group $resourceGroupName \
    --route-table-name $routeTableName \
    --name "routeToFirewall" \
    --next-hop-ip-address $firewallPrivateIp

# Create a network interface in VNet1
nicName="myVMNIC"
vmPublicIpName="myVMPublicIP"

# Create Public IP for the firewall
az network public-ip create \
    --resource-group $resourceGroupName \
    --name $vmPublicIpName \
    --sku "Standard" \
    --location $location

az network nic create \
    --resource-group $resourceGroupName \
    --name $nicName \
    --vnet-name $vnet1Name \
    --subnet $subnet1Name

# Associate public IP with NIC
az network nic ip-config update \
    --resource-group $resourceGroupName \
    --nic-name $nicName \
    --name "ipconfig1" \
    --public-ip-address $vmPublicIpName

# Create a VM in VNet1
az vm create \
    --resource-group $resourceGroupName \
    --name $vmName \
    --size $vmSize \
    --nics $nicName \
    --image Ubuntu2204 \
    --admin-username $adminUsername \
    --admin-password $adminPassword \
    --storage-sku "Standard_LRS" \
