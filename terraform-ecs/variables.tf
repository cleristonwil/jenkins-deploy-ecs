variable "cluster_name" {
  description = "Nome do cluster ECS"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "security_group_ids" {
  description = "IDs dos Security Groups"
  type        = list(string)
}

variable "instance_type" {
  description = "Tipo de instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nome do par de chaves SSH"
  type        = string
}

variable "min_size" {
  description = "Número mínimo de instâncias no ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Número máximo de instâncias no ASG"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Capacidade desejada de instâncias no ASG"
  type        = number
  default     = 2
}

variable "ebs_volume_size" {
  description = "Tamanho do volume EBS em GB"
  type        = number
  default     = 12
}

variable "task_definition_family" {
  description = "Família da definição de tarefa"
  type        = string
}

variable "container_name" {
  description = "Nome do container"
  type        = string
}

variable "container_image" {
  description = "URI da imagem do container"
  type        = string
}

variable "container_port" {
  description = "Porta do container"
  type        = number
}

variable "service_name" {
  description = "Nome do serviço ECS"
  type        = string
}

variable "lb_name" {
  description = "Nome do Load Balancer"
  type        = string
}

variable "target_group_name" {
  description = "Nome do Target Group"
  type        = string
}

variable "aws_region" {
  description = "AZ AWS"
  type        = string
  default     = "us-east-1"
}

variable "ecr_image_tag" {
  description = "Tag da imagem ECR"
  type        = string
  default     = "latest" # Valor padrão
}