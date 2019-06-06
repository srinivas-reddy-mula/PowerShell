######################################<<<<<<<<<<<<<<<<<<<<<<<<<  VARIABLES FOR FUTURE PURPOSE  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>############################
$group_name = 'ntier'
$location = 'Central US'
$network_name = 'Ntier'
$address_prefix = '192.168.0.0/16'
$subnet1_name = 'web'
$web_address = '192.168.0.0/24'
$subnet2_name = 'db'
$db_address = '192.168.1.0/24'
$subnet3_name = 'manage'
$manage_address = '192.168.2.0/24'
$nsg_name1 = 'web'
$nsg_name2 = 'db' 
$nsg_name3 = 'manage'
$nic_card1 = 'NIC1_WEB'
$nic_card2 = 'NIC2_DB'
$nic_card3 = 'NIC3_MANAGE'
$ip_configuration0 = 'web_ipconf'
$ip_configuration1 = 'db_ipconf'
$ip_configuration2 = 'manage_ipconf'  ### IP CONFIGURATION VARIABLE
$ip_public0 = 'web_ip'
$ip_public1=  'db_ip'
$ip_public2=  'manage_ip'  ### public ip names
$IP_PUBLIC0 = 'WEB_IP'
$IP_PUBLIC1 = 'DB_IP'
$IP_PUBLIC2 = 'MANAGE_IP'   ### PUBLIC IP OBJECTS
#######################################<<<<<<<<<<<<<<<<<<<<< RESOURCE GROUP CREATION  >>>>>>>>>>>>>>>>>>>>>>>>>>>>#####################################
# creating resource group
Write-Host 'Resource group>>' $group_name 'is creating'
$rg_name = New-AzResourceGroup -Name $group_name -Location $location
if ($rg_name) {
    Write-Host 'Resource group>>' $group_name 'is created'    
}

################################################<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< SUBNETS CREATION  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>######################
# creating subnet1 as WEB 
Write-Host 'Subnet>>' $subnet1_name 'is creating'
$web_subnet = New-AzVirtualNetworkSubnetConfig -Name $subnet1_name -AddressPrefix $web_address
if ($web_subnet) {
    Write-Host 'Subnet1>>' $subnet1_name 'is created'
}



# creating subnet2 as DB 
Write-Host 'Subnet>>' $subnet2_name 'is creating'
$db_subnet = New-AzVirtualNetworkSubnetConfig -Name $subnet2_name -AddressPrefix $db_address
if ($db_subnet) {
    Write-Host 'Subnet1>>' $subnet2_name 'is created'
}



# creating subnet3 as MANAGE 
Write-Host 'Subnet>>' $subnet3_name 'is creating'
$manage_subnet = New-AzVirtualNetworkSubnetConfig -Name $subnet3_name -AddressPrefix $manage_address
if ($manage_subnet) {
    Write-Host 'Subnet3>>' $subnet3_name 'is created'
}
########################################<<<<<<<<<<<<<<<<<<<<<<<<<<<<< VNET CREATION  >>>>>>>>>>>>>>>>>>>>>>>##################################
### creating vnet
Write-Host 'Vnet>>' $network_name 'is creating'
$vnet = New-AzVirtualNetwork -Name $network_name -ResourceGroupName $group_name -Location $location -AddressPrefix $address_prefix -Subnet $web_subnet, $db_subnet, $manage_subnet
if ($vnet) {
    Write-Host 'Vnet>>' $network_name 'is created'
}
###############################################<<<<<<<<<<<<<<<<<<<<  SECURITY RULE CREATION  >>>>>>>>>>>>>>>>>>>>>>>>>#############################
### creating rule 22   
Write-Host ' nsg rule 22 SSH is creating'
$rule_ssh = New-AzNetworkSecurityRuleConfig -Name sshallow -Protocol Tcp -SourcePortRange * -DestinationPortRange 22 -Access Allow -Priority 1000 -Direction Inbound -SourceAddressPrefix * -DestinationAddressPrefix *
if ($rule_ssh) {
    Write-Host ' nsg rule 22 SSH is created'
}


### creating rule 80 HTTP
Write-Host ' nsg rule 80 HTTP is creating'
$rule_http = New-AzNetworkSecurityRuleConfig -Name internetaloow -Protocol Tcp -SourcePortRange * -DestinationPortRange 80 -Access Allow -Priority 1020 -Direction Inbound -SourceAddressPrefix * -DestinationAddressPrefix *
if ($rule_http) {
    Write-Host ' nsg rule 80 HTTP is created'
}
### creating rule 3389
Write-Host ' nsg rule 3389 RDP is creating'
$rule_rdp = New-AzNetworkSecurityRuleConfig -Name RDP -Protocol Tcp -SourcePortRange * -DestinationPortRange 3389 -Access Allow -Priority 1030 -Direction Inbound -SourceAddressPrefix * -DestinationAddressPrefix *
if ($rule_rdp) {
    Write-Host ' nsg rule 3389 RDP is created'
}

############################################<<<<<<<<<<<<<<<<<<  NETWORK SECURITY GROUPS CREATION  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#####################
### creating Security group for WEB subnet
Write-Host 'nsg >>' $nsg_name1 'is creating'
$NSG_WEB = New-AzNetworkSecurityGroup -Name $nsg_name1 -Location $location -ResourceGroupName $group_name -SecurityRules $rule_ssh, $rule_http, $rule_rdp
Set-AzVirtualNetworkSubnetConfig -Name $subnet1_name -VirtualNetwork $vnet -AddressPrefix $web_address -NetworkSecurityGroup $NSG_WEB
if ($NSG_WEB) {
    Write-Host 'nsg >>' $nsg_name1 'is created'
}

### creating Security group for DB subnet
Write-Host 'nsg >>' $nsg_name2 'is creating'
$NSG_DB = New-AzNetworkSecurityGroup -Name $nsg_name2 -Location $location -ResourceGroupName $group_name -SecurityRules $rule_ssh, $rule_http, $rule_rdp
Set-AzVirtualNetworkSubnetConfig -Name $subnet2_name -VirtualNetwork $vnet -AddressPrefix $db_address -NetworkSecurityGroup $NSG_DB
if ($NSG_DB) {
    Write-Host 'nsg >>' $nsg_name2 'is created'
}

### creating Security group for MANAGE subnet
Write-Host 'nsg >>' $nsg_name3 'is creating'
$NSG_MANAGE = New-AzNetworkSecurityGroup -Name $nsg_name3 -Location $location -ResourceGroupName $group_name -SecurityRules $rule_ssh, $rule_http, $rule_rdp
Set-AzVirtualNetworkSubnetConfig -Name $subnet3_name -VirtualNetwork $vnet -AddressPrefix $manage_address -NetworkSecurityGroup $NSG_MANAGE
if ($NSG_MANAGE) {
    Write-Host 'nsg >>' $nsg_name3 'is created'
}
$NSG = $NSG_WEB, $NSG_DB, $NSG_MANAGE
$test0 = $vnet.Subnets[0]
$test1 = $vnet.Subnets[1]
$test2 = $vnet.Subnets[2]

#####################################<<<<<<<<<<  PUBLIC IP CREATION  >>>>>>>>>>>>>>>>>>>>############################################
### public ipaddress creation for WEB
Write-Host 'public ipaddress creation>>' $ip_public0
$IP_PUBLIC0 = New-AzPublicIpAddress -Name $ip_public0 -ResourceGroupName $group_name -AllocationMethod "Dynamic" -Location $location
if ($IP_PUBLIC0) {
    Write-Host 'public ipaddress is created'$ip_public0.ipaddress
}
### public ipaddress creation for DB
Write-Host 'public ipaddress creation>>' $ip_public1
$IP_PUBLIC1 = New-AzPublicIpAddress -Name $ip_public1 -ResourceGroupName $group_name -AllocationMethod "Dynamic" -Location $location
if ($IP_PUBLIC1) {
    Write-Host 'public ipaddress is created'$ip_public1.ipaddress
}

### public ipaddress creation for MANAGE
Write-Host 'public ipaddress creation>>' $ip_public2
$IP_PUBLIC2 = New-AzPublicIpAddress -Name $ip_public2 -ResourceGroupName $group_name -AllocationMethod "Dynamic" -Location $location
if ($IP_PUBLIC2) {
    Write-Host 'public ipaddress is created'$ip_public2.ipaddress
}




############################################<<<<<<<<<<<< IP CONFIGURATION CREATION >>>>>>>>>>>>>>>>>>>#################################
## ip cinfiguration for web vm
    Write-Host 'ipconfiguration>>' $ip_configuration0 ' is creating'
    $ip_conf0 = New-AzNetworkInterfaceIpConfig -Name $ip_configuration0 -Subnet $test0 -PublicIpAddress $IP_PUBLIC0
    if ($ip_conf0) {
        Write-Host 'ipconfiguration>>' $ip_configuration0 ' is created'
    }

## ip cinfiguration for db vm
Write-Host 'ipconfiguration>>' $ip_configuration1 ' is creating'
$ip_conf1 = New-AzNetworkInterfaceIpConfig -Name $ip_configuration1 -Subnet $test1 -PublicIpAddress $IP_PUBLIC1
if ($ip_conf1) {
    Write-Host 'ipconfiguration>>' $ip_configuration1 ' is created'
}

## ip cinfiguration for manage vm
Write-Host 'ipconfiguration>>' $ip_configuration2 ' is creating'
$ip_conf2 = New-AzNetworkInterfaceIpConfig -Name $ip_configuration2 -Subnet $test2 -PublicIpAddress $IP_PUBLIC2
if ($ip_conf2) {
    Write-Host 'ipconfiguration>>' $ip_configuration2 ' is created'
}

################################################<<<<<<<<<<<<<<<<  NIC CREATION   >>>>>>>>>>>>>>>>>>>>>>>>>>>>>###########################
### creating network interface card for WEB VM
Write-Host 'nic interface >>' $nic_card1 ' is creating' 
$NIC0 = New-AzNetworkInterface -Name $nic_card1 -ResourceGroupName $group_name -Location $location -IpConfiguration $ip_conf0 -NetworkSecurityGroup $NSG_WEB
if ($NIC0) {
    Write-Host 'nic interface >>' $nic_card1 ' is created'
}

### creating network interface card for DB VM
Write-Host 'nic interface >>' $nic_card2 ' is creating' 
$NIC1 = New-AzNetworkInterface -Name $nic_card2 -ResourceGroupName $group_name -Location $location -IpConfiguration $ip_conf1 -NetworkSecurityGroup $NSG_DB
if ($NIC1) {
    Write-Host 'nic interface >>' $nic_card2 ' is created'
}

### creating network interface card for WEB VM
Write-Host 'nic interface >>' $nic_card3 ' is creating' 
$NIC2 = New-AzNetworkInterface -Name $nic_card3 -ResourceGroupName $group_name -Location $location -IpConfiguration $ip_conf2 -NetworkSecurityGroup $NSG_MANAGE
if ($NIC2) {
    Write-Host 'nic interface >>' $nic_card3 ' is created'
}




#######################################<<<<<<<<<<<<<<<<<<<<<<<<<  VM CREATION  >>>>>>>>>>>>>>>>>>>>>>>>>>>>################################
### Credentials for VM
$username = Read-Host 'enter vm username' 
$password = Read-Host "Enter Password" -AsSecureString

#### vm creation 
for($i=1;$i -lt 4;$i++){
    $subnet_selection = Read-Host 'Select subnet 1:WEB  2:DB  3:MANAGE '
    if ($subnet_selection -eq 1) {
        
        $ch = Read-Host 'enter 1: Windows   2: Linux'
        if ($ch -eq 1) {
            Write-Host 'Windows vmcreation>> windows10 pro is creating'
            $cred = New-Object System.Management.Automation.PSCredential ($username, $password)
            $vm_config = New-AzVMConfig -VMName windows10 -VMSize Standard_B1s | `
                Set-AzVMOperatingSystem -Windows -ComputerName windows10 -Credential $cred | `
                 Set-AzVMSourceImage -PublisherName "MicrosoftWindowsDesktop" -Offer "Windows-10" -Sku "rs5-pro" -Version latest | `
                Add-AzVMNetworkInterface -Id $NIC0.Id
    
            $vm = New-AzVM -ResourceGroupName $group_name -Location $location -VM $vm_config
            if ($vm) {
                Write-Host 'Windows vm creation>> windows10 pro is created'
            }
             
        }
                
            
        
            
        if ($ch -eq 2) {
            Write-Host 'Linuxvm creation>> ubuntu 18.04 is creating'
            $cred = New-Object System.Management.Automation.PSCredential ($username, $password)
            $vm_config = New-AzVMConfig -VMName ubuntu18 -VMSize Standard_B1s | `
                Set-AzVMOperatingSystem -Linux -ComputerName ubuntu18 -Credential $cred | `
                Set-AzVMSourceImage -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS" -Version "latest" | `
                Add-AzVMNetworkInterface -Id $NIC0.Id
    
            $vm = New-AzVM -ResourceGroupName $group_name -Location $location -VM $vm_config 
            if ($vm) {
                Write-Host 'Linux vm creation>> ubuntu 18.04 is created'
            }
             
        }
    }

    if ($subnet_selection -eq 2) {
        
        $ch = Read-Host 'enter 1 Windows   2 Linux'
        if ($ch -eq 1) {
            Write-Host 'Windows vmcreation>> windows10 pro is creating'
            $cred = New-Object System.Management.Automation.PSCredential ($username, $password)
            $vm_config = New-AzVMConfig -VMName windows10 -VMSize Standard_B1s | `
                Set-AzVMOperatingSystem -Windows -ComputerName windows10 -Credential $cred | `
                 Set-AzVMSourceImage -PublisherName "MicrosoftWindowsDesktop" -Offer "Windows-10" -Sku "rs5-pro" -Version latest | `
                Add-AzVMNetworkInterface -Id $NIC1.Id
    
            $vm = New-AzVM -ResourceGroupName $group_name -Location $location -VM $vm_config
            if ($vm) {
                Write-Host 'Windows vm creation>> windows10 pro is created'
            }
             
        }
                
            
        
            
        if ($ch -eq 2) {
            Write-Host 'Linuxvm creation>> ubuntu 18.04 is creating'
            $cred = New-Object System.Management.Automation.PSCredential ($username, $password)
            $vm_config = New-AzVMConfig -VMName ubuntu18 -VMSize Standard_B1s | `
                Set-AzVMOperatingSystem -Linux -ComputerName ubuntu18 -Credential $cred | `
                Set-AzVMSourceImage -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS" -Version "latest" | `
                Add-AzVMNetworkInterface -Id $NIC1.Id
    
            $vm = New-AzVM -ResourceGroupName $group_name -Location $location -VM $vm_config 
            if ($vm) {
                Write-Host 'Linux vm creation>> ubuntu 18.04 is created'
            }
             
        }
    }

    if ($subnet_selection -eq 3) {
        $ch = Read-Host 'enter 1 Windows   2 Linux'
        
        if ($ch -eq 1) {
            Write-Host 'Windows vmcreation>> windows10 pro is creating'
            $cred = New-Object System.Management.Automation.PSCredential ($username, $password)
            $vm_config = New-AzVMConfig -VMName windows10 -VMSize Standard_B1s | `
                Set-AzVMOperatingSystem -Windows -ComputerName windows10 -Credential $cred | `
                Set-AzVMSourceImage -PublisherName "MicrosoftWindowsDesktop" -Offer "Windows-10" -Sku "rs5-pro" -Version latest | `
                Add-AzVMNetworkInterface -Id $NIC2.Id
    
            $vm = New-AzVM -ResourceGroupName $group_name -Location $location -VM $vm_config
            if ($vm) {
                Write-Host 'Windows vm creation>> windows10 pro is created'
            }
             
        }
                
            
        
            
        if ($ch -eq 2) {
            Write-Host 'Linuxvm creation>> ubuntu 18.04 is creating'
            $cred = New-Object System.Management.Automation.PSCredential ($username, $password)
            $vm_config = New-AzVMConfig -VMName ubuntu18 -VMSize Standard_B1s | `
                Set-AzVMOperatingSystem -Linux -ComputerName ubuntu18 -Credential $cred | `
                Set-AzVMSourceImage -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS" -Version "latest" | `
                Add-AzVMNetworkInterface -Id $NIC2.Id
    
            $vm = New-AzVM -ResourceGroupName $group_name -Location $location -VM $vm_config 
            if ($vm) {
                Write-Host 'Linux vm creation>> ubuntu 18.04 is created'
            }
             
        }
    }
}