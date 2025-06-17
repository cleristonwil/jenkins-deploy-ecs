output "cluster_name" {
  value = module.ecs_cluster.cluster_name
}

output "service_name" {
  value = module.ecs_cluster.service_name
}

output "load_balancer_dns" {
  value = module.ecs_cluster.load_balancer_dns
}