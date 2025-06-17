output "cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "service_name" {
  value = aws_ecs_service.service.name
}

output "load_balancer_dns" {
  value = aws_lb.webapp_lb.dns_name
}