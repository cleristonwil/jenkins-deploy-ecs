# Jenkins CI/CD com Terraform e AWS ECS

Este projeto demonstra como implementar um pipeline CI/CD completo usando Jenkins, Terraform e AWS ECS para automatizar o deploy de aplicações containerizadas.

## 📋 Visão Geral

O projeto consiste em 3 pipelines Jenkins:

1. **Deploy ECS** - Cria a infraestrutura AWS usando Terraform
2. **App Deploy** - Faz build da aplicação e deploy no ECS
3. **Destroy ECS** - Remove todos os recursos AWS criados

## 📁 Estrutura do Repositório

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

## 🔧 Pré-requisitos

### 1. Plugins do Jenkins

Instale os seguintes plugins no Jenkins:

- **Terraform Plugin** - Para executar comandos Terraform
- **AWS Credentials Plugin** - Para gerenciar credenciais AWS
- **Pipeline Graph View Plugin** - Para visualizar o pipeline graficamente
- **Pipeline Analysis Plugin** - Para análise e métricas do pipeline
- **Pipeline Stage View Plugin** - Para visualizar estágios do pipeline

**Como instalar:**
1. Vá em `Gerenciar Jenkins` > `Plugin Manager`
2. Na aba `Available`, procure por cada plugin
3. Marque a caixa de seleção e clique em `Install without restart`

### 2. Usuário Programático AWS

1. **Criar usuário IAM:**
   - Acesse AWS Console > IAM > Users
   - Clique em `Add user`
   - Nome: `jenkins-terraform-user`
   - Access type: `Programmatic access`

2. **Configurar permissões:**
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
   > ⚠️ **Para produção:** Use permissões mais restritivas. Esta permissão de administrador é apenas para testes.

3. **Salvar credenciais:**
   - Anote o `Access Key ID` e `Secret Access Key`
   - **IMPORTANTE:** Exclua este usuário após os testes para segurança

### 3. Configurar Credenciais no Jenkins

1. Vá em `Gerenciar Jenkins` > `Security` > `Manage Credentials`
2. Clique em `Global` > `Add Credentials`
3. Selecione `AWS Credentials`
4. Preencha:
   - **ID:** `jk-aws-credentials` (usado nos Jenkinsfiles)
   - **Access Key ID:** Sua access key da AWS
   - **Secret Access Key:** Sua secret key da AWS
   - **Description:** Jenkins AWS Credentials

### 4. Repositório ECR na AWS

1. **Criar repositório ECR:**
   ```bash
   aws ecr create-repository --repository-name sua-aplicacao --region us-east-1
   ```

2. **Ou via Console AWS:**
   - AWS Console > ECR > Repositories
   - Clique em `Create repository`
   - Nome: `sua-aplicacao`
   - Visibilidade: `Public` (para testes)

3. **Obter comandos de push:**
   - Clique no repositório criado
   - Clique em `View push commands`
   - **Substitua os valores no `Jenkinsfile-app`** pelos comandos gerados

### 5. Instalações no Servidor Jenkins

#### AWS CLI
```bash
# Ubuntu/Debian
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verificar instalação
aws --version
```

#### Docker
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Adicionar usuário jenkins ao grupo docker
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Verificar instalação
docker --version
```

#### Terraform
```bash
# Download e instalação
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verificar instalação
terraform --version
```

### 6. Permissões do Usuário Jenkins

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

## 🚀 Como Usar

### 1. Configurar Jobs no Jenkins

Para cada pipeline, crie um novo job:

1. **Job: Deploy-ECS**
   - New Item > Pipeline
   - Pipeline > Definition: `Pipeline script from SCM`
   - SCM: Git
   - Repository URL: `sua-url-do-repositorio`
   - Script Path: `jenkins-pipeline/Jenkinsfile-deploy-ecs`

2. **Job: App-Deploy**
   - Script Path: `jenkins-pipeline/Jenkinsfile-app`

3. **Job: Destroy-ECS**
   - Script Path: `jenkins-pipeline/Jenkinsfile-destroy-ecs`

### 2. Customizar Jenkinsfile-app

No arquivo `jenkins-pipeline/Jenkinsfile-app`, substitua:

```bash
# Substituir pelos comandos do seu ECR
aws ecr get-login-password --region SUA_REGIAO | docker login --username AWS --password-stdin SEU_ACCOUNT_ID.dkr.ecr.SUA_REGIAO.amazonaws.com
docker build -t SEU_REPO_NAME:latest .
docker tag SEU_REPO_NAME:latest SEU_ACCOUNT_ID.dkr.ecr.SUA_REGIAO.amazonaws.com/SEU_REPO_NAME:latest
docker push SEU_ACCOUNT_ID.dkr.ecr.SUA_REGIAO.amazonaws.com/SEU_REPO_NAME:latest
```

### 3. Ordem de Execução

1. **Execute primeiro:** `Deploy-ECS` - Cria a infraestrutura
2. **Execute segundo:** `App-Deploy` - Faz deploy da aplicação
3. **Execute por último:** `Destroy-ECS` - Remove recursos (quando necessário)

## 💰 Custos AWS

Este projeto cria recursos que podem gerar custos na AWS:

- **ECS Cluster** (Fargate)
- **Application Load Balancer**
- **NAT Gateway**
- **ECR Repository**

> 💡 **Dica:** Execute o pipeline `Destroy-ECS` após os testes para evitar custos desnecessários.

## 🔍 Troubleshooting

### Erro de Permissão Docker
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Erro de Credenciais AWS
- Verifique se as credenciais estão corretas no Jenkins
- Teste manualmente: `aws sts get-caller-identity`

### Erro de Terraform
```bash
# Limpar cache do Terraform
rm -rf .terraform*
terraform init
```

### Erro de ECR
- Verifique se o repositório ECR existe
- Confirme se a região está correta
- Teste o login manual: `aws ecr get-login-password`

## 📚 Recursos Adicionais

- [Documentação Jenkins](https://www.jenkins.io/doc/)
- [Documentação Terraform](https://developer.hashicorp.com/terraform/docs)
- [Documentação AWS ECS](https://docs.aws.amazon.com/ecs/)
- [Documentação AWS ECR](https://docs.aws.amazon.com/ecr/)

## ⚠️ Avisos Importantes

1. **Segurança:** Remova o usuário AWS após os testes
2. **Custos:** Execute `Destroy-ECS` para limpar recursos
3. **Produção:** Use permissões IAM mais restritivas
4. **Backup State:** Configure remote state para Terraform em produção

## 🤝 Contribuição

Este é um projeto educacional. Sinta-se livre para fazer melhorias e adaptações conforme sua necessidade.

---

**Desenvolvido para fins educacionais e demonstração de CI/CD com Jenkins, Terraform e AWS.**