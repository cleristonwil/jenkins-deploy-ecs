module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  cluster_name       = "jk-webapp-cluster"
  vpc_id             = "vpc-0c6204a6954c34d2d"
  security_group_ids = ["sg-08e7064c5471ebf66"]
  instance_type      = "t2.micro"
  key_name           = "vscode-key"
  min_size           = 2
  max_size           = 2
  desired_capacity   = 2
  ebs_volume_size    = 30

  task_definition_family = "jk-webapp-td"
  container_name         = "jk-webapp-ctr"
  container_image        = "503561427708.dkr.ecr.us-east-1.amazonaws.com/jk-webapp:latest"
  container_port         = 3000

  service_name      = "jk-webapp-svc"
  lb_name           = "jk-webapp-lb"
  target_group_name = "jk-webapp-tg"
}