variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

# Configure the Azure Resource Manager Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}


resource "azurerm_network_interface" "prdwebpudinter02" {
    name = "prdwebpudinter02"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.prd.name}"
    network_security_group_id = "${azurerm_network_security_group.prdwebNSG.id}"

    ip_configuration {
        name = "prdconfiguration02"
        subnet_id = "${azurerm_subnet.prdpublic.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id = "${azurerm_public_ip.prdweb02pub.id}"
    }
}

resource "azurerm_virtual_machine" "prdweb02" {
    name = "prdweb02"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.prd.name}"
    network_interface_ids = ["${azurerm_network_interface.prdwebpudinter02.id}"]
    vm_size = "Standard_A0"


    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2008-R2-SP1"
        version = "latest"
    }

    storage_os_disk {
        name = "myosdisk02"
        vhd_uri = "${azurerm_storage_account.prdswebacnt.primary_blob_endpoint}${azurerm_storage_container.prdswebcont.name}/myosdisk02.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "prdweb02"
        admin_username = "zenadmin"
        admin_password = "Redhat#12345"
    }

    os_profile_windows_config {
        provision_vm_agent = true
        enable_automatic_upgrades = false
    }
}
