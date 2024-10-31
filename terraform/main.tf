terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.7.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "cb40f2db-d006-4703-bf9e-7fda6377912b"
  features {}
}

# Resource group
resource "azurerm_resource_group" "rg-coachme" {
    name = "rg-coachme"
    location = "Canada Central"
}

# Virtual network
resource "azurerm_virtual_network" "vn-coachme" {
    name = "vn-coachme"
    location = azurerm_resource_group.rg-coachme.location
    resource_group_name = azurerm_resource_group.rg-coachme.name
    address_space = ["10.0.0.0/16"]
}

# Subnet app-service
resource "azurerm_subnet" "app-service" {
    name                 = "app-service"
    resource_group_name  = azurerm_resource_group.rg-coachme.name
    virtual_network_name = azurerm_virtual_network.vn-coachme.name
    address_prefixes     = ["10.0.2.0/24"]
    service_endpoints    = [
          "Microsoft.Sql",
        ]
    delegation {
        name = "delegation"
        service_delegation {
              actions = [
                  "Microsoft.Network/virtualNetworks/subnets/action",
                ]
              name    = "Microsoft.Web/serverFarms"
            }
        }  
}

# Subnet database
resource "azurerm_subnet" "database" {
    name                 = "database"
    resource_group_name  = azurerm_resource_group.rg-coachme.name
    virtual_network_name = azurerm_virtual_network.vn-coachme.name
    address_prefixes     = ["10.0.3.0/24"]
    service_endpoints    = [
          "Microsoft.Sql",
        ]
}

# App service plan
resource "azurerm_service_plan" "ASP-rgcoachme-9c49" {
  name                = "ASP-rgcoachme-9c49"
  resource_group_name = azurerm_resource_group.rg-coachme.name
  location            = azurerm_resource_group.rg-coachme.location
  os_type             = "Linux"
  sku_name            = "B1"
}

# App service
resource "azurerm_linux_web_app" "coachmee" {
    id                  = null
    name                = "coachmee"
    tags                = {}
    app_settings        = {
        # All of this should be stored in Azure keyvault and remote state should be prefered
        "CURRENT_ENV"                    = "Azure"
        "DB_HOST"                        = "coachmee.database.windows.net"
        "DB_NAME"                        = "db-coachme"
        "DB_PASSWORD"                    = "Pezzo121294!"
        "DB_USER"                        = "admin-enzo"
        "DJANGO_SECRET_KEY"              = "-womh$wyxc=k(5kf_f@*#fle630$va$pyu$&v$4*rs@ft^&g5n"
        "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"
        }
    virtual_network_subnet_id   = azurerm_subnet.app-service.id
    resource_group_name         = azurerm_resource_group.rg-coachme.name
    location                    = azurerm_service_plan.ASP-rgcoachme-9c49.location
    service_plan_id             = azurerm_service_plan.ASP-rgcoachme-9c49.id
    ftp_publish_basic_authentication_enabled            = false
    https_only                                          = true
    webdeploy_publish_basic_authentication_enabled      = false
    site_config {
        always_on         = false
        app_command_line          = <<-EOT
                gunicorn --bind=0.0.0.0:8000 todolist.wsgi:application
            EOT
        ftps_state                                   = "FtpsOnly"
        vnet_route_all_enabled                       = true
    }
    lifecycle {
    ignore_changes = [
      site_config[0].ip_restriction_default_action,
      site_config[0].scm_ip_restriction_default_action
    ]
  }
}

# SQL server
resource "azurerm_mssql_server" "sql-serv-coachmee" {
  name                         = "coachmee"
  resource_group_name          = azurerm_resource_group.rg-coachme.name
  location                     = azurerm_resource_group.rg-coachme.location
  version                      = "12.0"
  # All of this should be stored in Azure keyvault and remote state should be prefered
  administrator_login          = "admin-enzo"
  administrator_login_password = "Pezzo121294!"
  public_network_access_enabled = false
}

# SQL database
resource "azurerm_mssql_database" "db-coachme" {
    name = "db-coachme"
    server_id = azurerm_mssql_server.sql-serv-coachmee.id
    storage_account_type = "Local"
    lifecycle {
        prevent_destroy = true
    }
}

# Network Interface
resource "azurerm_network_interface" "pep-db-coachme-nic" {
  name                = "pep-db-coachme-nic"
  location            = azurerm_resource_group.rg-coachme.location
  resource_group_name = azurerm_resource_group.rg-coachme.name

  ip_configuration {
    name                          = "privateEndpointIpConfig.6884df33-d3d5-40ad-88a4-5889cd8170b2"
    subnet_id                     = azurerm_subnet.database.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "privatelink_database_windows_net" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg-coachme.name
}

# Private endpoint
resource "azurerm_private_endpoint" "pep-db-coachme" {
  name                = "pep-db-coachme"
  custom_network_interface_name = "pep-db-coachme-nic"
  location            = azurerm_resource_group.rg-coachme.location
  resource_group_name = azurerm_resource_group.rg-coachme.name
  subnet_id           = azurerm_subnet.database.id

  private_dns_zone_group {
          name                 = "default"
          private_dns_zone_ids = [
              azurerm_private_dns_zone.privatelink_database_windows_net.id,
            ]
        }

  private_service_connection {
    name                           = "pep-db-coachme"
    private_connection_resource_id = azurerm_mssql_server.sql-serv-coachmee.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer",]
  }
}