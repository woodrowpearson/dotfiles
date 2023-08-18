module "qdrant" {
  source        = "CTOFriendly/qdrant/aws"
  version       = "0.0.1"
  region        = "us-west-2"
  instance_type = "c6g.medium"
  key_name      = "qdrant-home-key"
  disk_size     = 80
}

output "qdrant_ip" {
  value = module.qdrant.qdrant_ip
}