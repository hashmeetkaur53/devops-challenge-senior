# Resource group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.region
}

# VNet
resource "azurerm_virtual_network" "main" {
  name                = "simpletime-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Subnets
resource "azurerm_subnet" "public1" {
  name                 = "public-subnet-1"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "public2" {
  name                 = "public-subnet-2"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private1" {
  name                 = "private-subnet-1"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_subnet" "private2" {
  name                 = "private-subnet-2"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.11.0/24"]
}

# User-assigned managed identity for AKS (optional but best practice)
resource "azurerm_user_assigned_identity" "aks" {
  name                = "aks-identity"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "simpletimeaks"

  default_node_pool {
    name                = "default"
    node_count          = var.node_count
    vm_size             = "Standard_DS2_v2"
    vnet_subnet_id      = azurerm_subnet.private1.id
    # enable_auto_scaling = false
    os_disk_size_gb     = 30
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_policy      = "azure"
    service_cidr        = "10.0.100.0/24"
    dns_service_ip      = "10.0.100.10"
    # docker_bridge_cidr  = "172.17.0.1/16"
    load_balancer_sku   = "standard"
  }
}

# Public IP for LB
resource "azurerm_public_ip" "app_lb" {
  name                = "simpletime-lb-publicip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Output kubeconfig for Kubernetes Provider
output "kube_config" {
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}

# Kubernetes provider for workload deployment
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.main.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate)
}

# Kubernetes Deployment for SimpleTimeService
resource "kubernetes_deployment" "simpletimeservice" {
  metadata {
    name = "simpletimeservice"
    labels = {
      app = "simpletimeservice"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "simpletimeservice"
      }
    }
    template {
      metadata {
        labels = {
          app = "simpletimeservice"
        }
      }
      spec {
        container {
          name  = "simpletimeservice"
          image = var.docker_image
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

# Kubernetes Service (LoadBalancer)
resource "kubernetes_service" "sts_lb" {
  metadata {
    name = "simpletimeservice-lb"
  }
  spec {
    selector = {
      app = kubernetes_deployment.simpletimeservice.metadata[0].labels.app
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8080
    }
    type            = "LoadBalancer"
    load_balancer_ip = azurerm_public_ip.app_lb.ip_address
  }
}
