# Jenkins Deploy ECS - Pipeline CI/CD

Este projeto demonstra como implementar um pipeline CI/CD completo usando Jenkins, Terraform e AWS ECS para automatizar o deploy de aplicações containerizadas.

## 🏗️ Arquitetura do Projeto

O projeto consiste em 3 pipelines Jenkins:

- **Deploy ECS** - Cria a infraestrutura AWS usando Terraform
- **App Deploy** - Faz build da aplicação e deploy no ECS  
- **Destroy ECS** - Remove todos os recursos AWS criados

### 📁 Estrutura do Repositório

```
├── app/
│   ├── Dockerfile
│   ├── index.html
│   └── style.css
├── jenkins-pipeline/
│   ├── Jenkinsfile-deploy-ecs
│   ├── Jenkinsfile-app
│   └── Jenkinsfile-destroy-ecs
└── terraform-ecs/
    ├── main.tf
    ├── outputs.tf
    ├── provider.tf
    ├── variables.tf
    ├── terraform.tfvars
    └── modules/
        └── ecs-cluster/
            ├── main.tf
            ├── outputs.tf
            └── variables.tf
```

## ⚙️ Pré-requisitos

### 1. Plugins Jenkins

Instale os seguintes plugins no Jenkins:

- **Terraform Plugin** - Para executar comandos Terraform
- **AWS Credentials Plugin** - Para gerenciar credenciais AWS
- **Pipeline Graph View Plugin** - Para visualizar o pipeline graficamente
- **Pipeline Analysis Plugin** - Para análise e métricas do pipeline
- **Pipeline Stage View Plugin** - Para visualizar estágios do pipeline

**Como instalar:**
- Vá em `Gerenciar Jenkins` > `Plugin Manager`
- Na aba `Available`, procure por cada plugin
- Marque a caixa de seleção e clique em `Install without restart`

### 2. Configurar Credenciais AWS

**Criar usuário IAM:**
- Acesse AWS Console > IAM > Users
- Clique em `Add user`
- Nome: `jenkins-terraform-user`
- Access type: `Programmatic access`

**Configurar permissões:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
```

⚠️ **Para produção:** Use permissões mais restritivas. Esta permissão de administrador é apenas para testes.

**Salvar credenciais:**
- Anote o `Access Key ID` e `Secret Access Key`
- **IMPORTANTE:** Exclua este usuário após os testes para segurança

### 3. Configurar Credenciais no Jenkins

- Vá em `Gerenciar Jenkins` > `Security` > `Manage Credentials`
- Clique em `Global` > `Add Credentials`
- Selecione `AWS Credentials`
- Preencha:
  - ID: `jk-aws-credentials` (usado nos Jenkinsfiles)
  - Access Key ID: Sua access key da AWS
  - Secret Access Key: Sua secret key da AWS
  - Description: Jenkins AWS Credentials

### 4. Criar Repositório ECR

**Via AWS CLI:**
```bash
aws ecr create-repository --repository-name sua-aplicacao --region us-east-1
```

**Ou via Console AWS:**
- AWS Console > ECR > Repositories
- Clique em `Create repository`
- Nome: `sua-aplicacao`
- Visibilidade: `Public` (para testes)

**Obter comandos de push:**
- Clique no repositório criado
- Clique em `View push commands`
- Substitua os valores no `Jenkinsfile-app` pelos comandos gerados

## 🖥️ Instalação de Dependências no Servidor Jenkins

### AWS CLI
```bash
# Ubuntu/Debian
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verificar instalação
aws --version
```

### Docker
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Adicionar usuário atual ao grupo docker (para não precisar de sudo)
sudo usermod -aG docker $USER

# Adicionar usuário jenkins ao grupo docker
sudo usermod -aG docker jenkins

# Reiniciar para aplicar as mudanças
sudo systemctl restart docker
sudo systemctl restart jenkins

# Verificar instalação
docker --version
```

⚠️ **Importante:** Faça logout e login novamente para que as permissões do Docker sejam aplicadas ao seu usuário.

### Terraform
```bash
# Download e instalação
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verificar instalação
terraform --version
```

### Configurar Permissões Finais
```bash
# Adicionar jenkins aos grupos necessários
sudo usermod -aG docker jenkins
sudo usermod -aG sudo jenkins

# Reiniciar Jenkins
sudo systemctl restart jenkins

# Verificar permissões (executar como usuário jenkins)
sudo -u jenkins docker ps
sudo -u jenkins terraform --version
sudo -u jenkins aws --version
```

## 📝 Configuração Obrigatória do terraform.tfvars

⚠️ **ATENÇÃO:** Antes de executar os pipelines, você **DEVE** editar o arquivo `terraform-ecs/terraform.tfvars` com seus dados específicos:

```hcl
# Substitua pelos seus valores
vpc_id = "vpc-xxxxxxxxx"           # ID da sua VPC
security_group_id = "sg-xxxxxxxxx" # ID do Security Group da sua VPC
ecr_repository_url = "123456789012.dkr.ecr.us-east-1.amazonaws.com/sua-aplicacao"
```

**Como obter esses valores:**

1. **VPC ID:** AWS Console > VPC > Your VPCs
2. **Security Group ID:** AWS Console > EC2 > Security Groups (escolha um da sua VPC)
3. **ECR Repository URL:** AWS Console > ECR > Repositories (copie o URI do repositório criado)

## 🔧 Configuração dos Pipelines Jenkins

Para cada pipeline, crie um novo job:

### Job: Deploy-ECS
- New Item > Pipeline
- Pipeline > Definition: `Pipeline script from SCM`
- SCM: Git
- Repository URL: `sua-url-do-repositorio`
- Script Path: `jenkins-pipeline/Jenkinsfile-deploy-ecs`

### Job: App-Deploy
- Script Path: `jenkins-pipeline/Jenkinsfile-app`

### Job: Destroy-ECS
- Script Path: `jenkins-pipeline/Jenkinsfile-destroy-ecs`

## 🚀 Configuração do ECR no Pipeline

No arquivo `jenkins-pipeline/Jenkinsfile-app`, substitua pelos comandos do seu ECR:

```bash
# Substituir pelos comandos do seu ECR
aws ecr get-login-password --region SUA_REGIAO | docker login --username AWS --password-stdin SEU_ACCOUNT_ID.dkr.ecr.SUA_REGIAO.amazonaws.com

docker build -t SEU_REPO_NAME:latest .
docker tag SEU_REPO_NAME:latest SEU_ACCOUNT_ID.dkr.ecr.SUA_REGIAO.amazonaws.com/SEU_REPO_NAME:latest
docker push SEU_ACCOUNT_ID.dkr.ecr.SUA_REGIAO.amazonaws.com/SEU_REPO_NAME:latest
```

## ▶️ Ordem de Execução

1. **Execute primeiro:** `Deploy-ECS` - Cria a infraestrutura
2. **Execute segundo:** `App-Deploy` - Faz deploy da aplicação  
3. **Execute por último:** `Destroy-ECS` - Remove recursos (quando necessário)

## 💰 Importante - Custos AWS

Este projeto cria recursos que podem gerar custos na AWS:

- **ECS Cluster** (EC2 - otimizado para free tier)
- **Application Load Balancer**
- **NAT Gateway**
- **ECR Repository**

💡 **Dica:** Execute o pipeline `Destroy-ECS` após os testes para evitar custos desnecessários.

## 🔍 Troubleshooting

### Erro de permissão Docker
```bash
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Erro de credenciais AWS
- Verifique se as credenciais estão corretas no Jenkins
- Teste manualmente: `aws sts get-caller-identity`

### Erro do Terraform
```bash
# Limpar cache do Terraform
rm -rf .terraform*
terraform init
```

### Erro no ECR
- Verifique se o repositório ECR existe
- Confirme se a região está correta
- Teste o login manual: `aws ecr get-login-password`

## ⚠️ Considerações de Segurança e Boas Práticas

- **Segurança:** Remova o usuário AWS após os testes
- **Custos:** Execute `Destroy-ECS` para limpar recursos
- **Produção:** Use permissões IAM mais restritivas
- **Backup State:** Configure remote state para Terraform em produção

---

## 🎯 Sobre o Projeto

Este é um projeto **educacional** que demonstra:

- **Pipeline CI/CD** completo com Jenkins
- **Infrastructure as Code** com Terraform
- **Containerização** com Docker
- **Deploy automatizado** no AWS ECS com EC2 (free tier friendly)
- **Melhores práticas** de DevOps

Sinta-se livre para fazer melhorias e adaptações conforme sua necessidade.

---

**Desenvolvido para fins educacionais e demonstração de CI/CD com Jenkins, Terraform e AWS.**