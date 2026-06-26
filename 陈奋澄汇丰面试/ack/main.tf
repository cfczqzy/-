provider "alicloud" {
  access_key = var.alicloud_access_key
  secret_key = var.alicloud_secret_key
  region = var.region
}

locals {
    service_cidr = "192.168.0.0/16"
    pod_cidr     = "10.81.0.0/16"
}

resource "alicloud_cs_managed_kubernetes" "k8s" {
  name         = var.cluster_name
  version      = "1.26.3-aliyun.1"
  cluster_spec = "ack.pro.small"
  vswitch_ids  = [alicloud_vswitch.vsw.id]
  new_nat_gateway  = true
  service_cidr   = local.service_cidr
  skip_set_certificate_authority = true
  encryption_provider_key  = data.alicloud_kms_keys.default.keys[0].key_id
  pod_cidr   = local.pod_cidr
  slb_internet_enabled  = true
  load_balancer_spec   = "slb.s1.small"
  worker_number  = 1
  availability_zone  = "cn-beijing-b"
  worker_instance_types  = ["ecs.g6.xlarge"]
  password = "Password123.com"
  worker_disk_category = "cloud_efficiency"
  worker_disk_size  = 40
  os_type = "Linux"
  platform = "CentOS"

dynamic "addons" {
     for_each = var.cluster_addons
    content {
     name   = lookup(addons.value, "name", var.cluster_addons)
     config = lookup(addons.value, "config", var.cluster_addons)
    }
    }
runtime = {
  name = "docker"
  version = "19.03.5"
}
}
