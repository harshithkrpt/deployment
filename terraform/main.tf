########################
# VPC
########################

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

########################
# SECURITY GROUP
########################

resource "aws_security_group" "ecs" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################
# AURORA POSTGRES (CHEAP MODE)
########################

resource "aws_rds_cluster" "pg" {
  engine         = "aurora-postgresql"
  engine_mode    = "provisioned"

  database_name  = "todo"
  master_username = "postgres"
  master_password = "postgres"

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 1
  }

  skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "pg_instance" {
  cluster_identifier = aws_rds_cluster.pg.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.pg.engine
}

########################
# ECS
########################

resource "aws_ecs_cluster" "main" {
  name = "todo-cluster"
}

########################
# IAM ROLE FOR TASKS
########################

resource "aws_iam_role" "ecs_task_exec" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_attach" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

########################
# API TASK
########################

resource "aws_ecs_task_definition" "api" {
  family                   = "todo-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_exec.arn

  container_definitions = jsonencode([{
    name  = "api"
    image = var.api_image

    portMappings = [{
      containerPort = 8080
    }]

    environment = [
      { name="DB_URL", value="jdbc:postgresql://${aws_rds_cluster.pg.endpoint}:5432/todo" },
      { name="DB_USER", value="postgres" },
      { name="DB_PASS", value="postgres" }
    ]
  }])
}

########################
# UI TASK
########################

resource "aws_ecs_task_definition" "ui" {
  family                   = "todo-ui"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_exec.arn

  container_definitions = jsonencode([{
    name  = "ui"
    image = var.ui_image

    portMappings = [{
      containerPort = 80
    }]
  }])
}

########################
# SERVICES
########################

resource "aws_ecs_service" "api" {
  name            = "api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "ui" {
  name            = "ui"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ui.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
}