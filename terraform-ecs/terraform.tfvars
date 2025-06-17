cluster_name       = "jk-webapp-cluster"
# INSERIR A SUA VPC DEFAULT
vpc_id             = "vpc-0c6204a6954c34d2d"
# INSERIR O SECURITY GROUP DA VPC DEFAULT - LEMBRAR DE DAR PERMISSÃO INPUT PARA QUALQUER IP NA PORTA 80 PARA ACESSAR A APLICAÇÃO
security_group_ids = ["sg-08e7064c5471ebf66"]
instance_type      = "t2.micro"
# INSERIR A SUA CHAVE .PEM PARA ACESSO A INSTANCIA EC2
key_name           = "vscode-key"
min_size           = 2
max_size           = 2
desired_capacity   = 2
ebs_volume_size    = 30

task_definition_family = "jk-webapp-td"
container_name         = "jk-webapp-ctr"
# INSERIR AQUI O CAMINHO DO SEU REPOSITÓRIO ECR PUBLICO
container_image        = "INSIRA_AQUI_CAMINHO_REPOSITÓRIO_ECR_PUB/jk-webapp:latest"
container_port         = 3000

service_name      = "jk-webapp-svc"
lb_name           = "jk-webapp-lb"
target_group_name = "jk-webapp-tg"
