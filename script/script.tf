#create resource group
resource "azurerm_resource_group" "script-rg" {
  name     = "script-rg"
  location = "${var.location}"

  tags = {
    service     = "${var.service}"
    environment = "${var.environment}"
    team        = "${var.team}"
  }
}

# create availability set 

resource "azurerm_availability_set" "script-as" {
  managed                       = true
  platform_fault_domain_count   = "${var.platform_fault_domain_count}"
  platform_update_domain_count  = "${var.platform_update_domain_count}"
  location                      = "${var.location}"
  name                          = "script-as"
  resource_group_name           = "${azurerm_resource_group.script-rg.name}"
}

# creata nic

resource "azurerm_network_interface" "script-nic0" {
  name                          = "script-nic0"
  location                      = "${var.location}"
  count                         = 1
  resource_group_name           = "${azurerm_resource_group.script-rg.name}"
  network_security_group_id     = "${var.network_security_group_id}"
  enable_ip_forwarding          = "${var.enable_ip_forwarding}"
  enable_accelerated_networking = "${var.enable_accelerated_networking}"

  ip_configuration {
    name                          = "script-nic0"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "${var.private_ip_address_allocation}"
  }

# create virtual machine
  resource "azurerm_virtual_machine" "script0" {
  name                  = "pas-script0"
  location              = "southindia"
  count                 = 1
  resource_group_name   = "${azurerm_resource_group.script-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.script-nic0[count.index].id}"]
  vm_size               = "${var.vm_size}"
  availability_set_id   = "${azurerm_availability_set.script-as.id}"

  storage_os_disk {
    name              = "ideabfd-osdisk0"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${var.osdisk_type}"
    disk_size_gb      = "${var.osdisk_size}"
    os_type           = "Linux"
    disk_size_gb      = "128"
  }
  storage_data_disk {
    name              = ""
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "100"
    create_option     = "Empty"
    lun               = 1
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

 os_profile {
   computer_name  = "pas-script0"
   admin_username = "${var.admin_username}"
  }

