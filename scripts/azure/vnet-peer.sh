# az login
# az account set --subscription "0557bba5-5cab-4a81-9c29-bd557b67a8e2"
az group create --name vnet-peer-test --location northeurope

# Create Hub VNET
az network vnet create --resource-group vnet-peer-test --name VNetHub --address-prefix 10.255.0.0/16 --subnet-name Subnet1 --subnet-prefix 10.255.0.0/24

# Create VNET with Peers to new address space 1
az network vnet create --resource-group vnet-peer-test --name VNetSameAddress1      --address-prefix 10.0.0.0/16 --subnet-name Subnet1 --subnet-prefix 10.0.1.0/24
az network vnet create --resource-group vnet-peer-test --name VNetDifferentAddress1 --address-prefix 10.100.0.0/24 --subnet-name Subnet1 --subnet-prefix 10.100.0.0/26
az network vnet peering create --resource-group vnet-peer-test --name VNetSameAddress1ToVNetDifferentAddress1 --vnet-name VNetSameAddress1 --remote-vnet VNetDifferentAddress1 --allow-vnet-access
az network vnet peering create --resource-group vnet-peer-test --name VNetDifferentAddress1ToVNetSameAddress1 --vnet-name VNetDifferentAddress1 --remote-vnet VNetSameAddress1 --allow-vnet-access

# Create VNET with Peers to new address space 2
az network vnet create --resource-group vnet-peer-test --name VNetSameAddress2      --address-prefix 10.0.0.0/16 --subnet-name Subnet1 --subnet-prefix 10.0.1.0/24
az network vnet create --resource-group vnet-peer-test --name VNetDifferentAddress2 --address-prefix 10.100.1.0/24 --subnet-name Subnet1 --subnet-prefix 10.100.1.0/26
az network vnet peering create --resource-group vnet-peer-test --name VNetSameAddress1ToVNetDifferentAddress2 --vnet-name VNetSameAddress2 --remote-vnet VNetDifferentAddress2 --allow-vnet-access
az network vnet peering create --resource-group vnet-peer-test --name VNetDifferentAddress1ToVNetSameAddress2 --vnet-name VNetDifferentAddress2 --remote-vnet VNetSameAddress2 --allow-vnet-access

# Connect those different address VNETs to the VNets in the Hub
az network vnet peering create --resource-group vnet-peer-test --name VNetDifferentAddress1ToVNetHub --vnet-name VNetDifferentAddress1 --remote-vnet VNetHub --allow-vnet-access
az network vnet peering create --resource-group vnet-peer-test --name VNetDifferentAddress2ToVNetHub --vnet-name VNetDifferentAddress2 --remote-vnet VNetHub --allow-vnet-access

# Create small Vm and test connectivity
az network route-table create       --resource-group vnet-peer-test --name VnetHubRouteTable
az network route-table route create --resource-group vnet-peer-test --route-table-name HubRouteTable --name RouteToInternet --address-prefix 0.0.0.0/0 --next-hop-type VirtualNetworkGateway --next-hop-ip-address 10.3.0.254
az network public-ip create    --resource-group vnet-peer-test --name GatewayIP --allocation-method Static
az network vnet-gateway create --resource-group vnet-peer-test --name VNetGateway --public-ip-address GatewayIP --vnet VNetSameAddress1 --gateway-type Vpn --vpn-type RouteBased --sku VpnGw1 --no-wait

# Create VM and associate with the route table
az network nic create --resource-group net-peer-test --name MyNIC --vnet-name VNetSameAddress1 --subnet Subnet1 --network-security-group MyNSG
az vm create --resource-group net-peer-test --name MyVM --nics MyNIC --image UbuntuLTS --size Standard_B1s --admin-username azureuser --generate-ssh-keys



#----------------------------------------------------------
# Delete RG
az group delete --resource-group vnet-peer-test 