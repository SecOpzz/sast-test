# ⚠️ INFRAESTRUTURA VULNERÁVEL - APENAS DEMONSTRAÇÃO
# Vulnerabilidades para Infrastructure as Code Security

# ❌ VULNERABILIDADE: Hardcoded Secrets
variable "database_password" {
  default = "SuperSecretPassword123!" # ❌ Senha hardcoded
}

variable "api_key" {
  default = "AKIAIOSFODNN7EXAMPLE" # ❌ Chave AWS hardcoded
}

# ❌ VULNERABILIDADE: S3 Bucket Publico
resource "aws_s3_bucket" "public_data" {
  bucket = "my-public-bucket-12345"
  
  # ❌ Bucket público
  acl = "public-read-write" # ❌ ACL pública permissiva
}

resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.public_data.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.public_data.arn}",
          "${aws_s3_bucket.public_data.arn}/*"
        ]
      }
    ]
  })
}

# ❌ VULNERABILIDADE: Security Groups Excessivamente Permissivos
resource "aws_security_group" "wide_open" {
  name        = "wide-open-sg"
  description = "Security group totalmente aberto"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # ❌ Todo o tráfego
    cidr_blocks = ["0.0.0.0/0"] # ❌ Todo mundo
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ❌ VULNERABILIDADE: EC2 sem IAM Role
resource "aws_instance" "web_server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  
  # ❌ Sem IAM Role - permissões excessivas
  iam_instance_profile = "" # ❌ Instância com permissões padrão
  
  # ❌ User Data com secrets
  user_data = <<-EOF
              #!/bin/bash
              export DB_PASSWORD="MyDatabasePass123"
              export API_KEY="secret-key-here"
              npm start
              EOF

  # ❌ Usando security group aberto
  vpc_security_group_ids = [aws_security_group.wide_open.id]

  # ❌ Key pair hardcoded
  key_name = "my-key-pair"
}

# ❌ VULNERABILIDADE: RDS Publicamente Acessível
resource "aws_db_instance" "public_database" {
  identifier           = "public-mysql-db"
  engine              = "mysql"
  instance_class      = "db.t2.micro"
  allocated_storage   = 20
  username            = "admin"
  password            = var.database_password # ❌ Senha hardcoded
  
  # ❌ Database público
  publicly_accessible = true # ❌ RDS exposto na internet
  
  # ❌ Backup longo
  backup_retention_period = 35 # ❌ Muito tempo de retenção
  skip_final_snapshot     = true # ❌ Sem snapshot final
}

# ❌ VULNERABILIDADE: IAM Policies Excessivamente Permissivas
resource "aws_iam_policy" "admin_policy" {
  name        = "AdminFullAccess"
  description = "Política com acesso total"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "*" # ❌ Acesso completo
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user" "deploy_user" {
  name = "deploy-user"
}

resource "aws_iam_user_policy_attachment" "admin_attach" {
  user       = aws_iam_user.deploy_user.name
  policy_arn = aws_iam_policy.admin_policy.arn
}

# ❌ VULNERABILIDADE: CloudTrail Desabilitado
# ❌ Não há configuração de CloudTrail para logging

# ❌ VULNERABILIDADE: KMS Key amplamente acessível
resource "aws_kms_key" "broad_access_key" {
  description = "KMS key com acesso amplo"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*" # ❌ Principal amplo demais
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# ❌ VULNERABILIDADE: Lambda com permissões excessivas
resource "aws_lambda_function" "vulnerable_lambda" {
  filename      = "lambda.zip"
  function_name = "vulnerable-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {
      DB_PASSWORD = var.database_password # ❌ Secret em variável de ambiente
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_admin" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # ❌ Política de admin
}

# ❌ VULNERABILIDADE: Configurações de logging desabilitadas
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/lambda/app"
  retention_in_days = 1 # ❌ Retenção muito curta
}
