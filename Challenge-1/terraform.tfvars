resource_group_name = "rg-task1"
location = "eastus"

tags = {
  "app" = "sample",
  "env" = "dev"
}
vnet_name = "vnet-001"
address_space = [ "192.168.0.0/16" ]
address_prefixes = [ "192.168.0.0/24","192.168.1.0/24"]
subnet_names = [ "web-subnet1" ,"app-subnet2"]

route_table_name = ["rt-subnet-web","rt-app-web","rt-db-web"]
subnet_route_prefixes = [ "" ]
subnet_ids = [ "/subscriptions/[subscription_id]/resourceGroups/rg-task1/providers/Microsoft.Network/virtualNetworks/vnet-001/subnets/web-subnet","/subscriptions/[subscription_id]/resourceGroups/rg-task1/providers/Microsoft.Network/virtualNetworks/vnet-001/subnets/app-subnet","/subscriptions/[subscription_id]/resourceGroups/rg-task1/providers/Microsoft.Network/virtualNetworks/vnet-001/subnets/db-subnet" ]

nsg_name = ["nsg-web-01","nsg-app-01","nsg-db-01"]



