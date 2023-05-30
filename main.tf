resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "public2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-gw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "route-table"
  }
}

resource "aws_route_table_association" "public-rta1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "public-rta2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_eip" "lb" {
  domain   = "vpc"
}

resource "aws_lb" "elb" {
  name               = "ecs-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = [aws_subnet.public1.id,aws_subnet.public2.id]

  tags = {
    Environment = "elb"
  }
}

resource "aws_lb_target_group" "ip-tg" {
  name        = "ip-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ip-tg.arn
  }
}

#resource "aws_lb_target_group_attachment" "tg-attachment" {
#  target_group_arn = aws_lb_target_group.ip-tg.arn
#  target_id        = aws_instance.test.id
#  port             = 80
#}

resource "aws_ecs_cluster" "cluster" {
  name = "ecs-cluster"
}

resource "aws_iam_role" "deployment-example-role" {
  name = "deployment-example-role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "deployment-example-role"
  }
}

resource "aws_ecs_task_definition" "deployment-example-task" {
  family = "deployment-example-task"
  cpu       = 256
  memory    = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/deployment-example-role"
  container_definitions = jsonencode([
    {
      name      = "deployment-nextjs-container"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-central-1.amazonaws.com/nextjs-application:latest"
      cpu       = 256
      memory    = 512
      essential = true
      execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/deployment-example-role",
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
  ])
}

resource "aws_ecs_service" "ecs-service" {
  name            = "ecs-service"
  launch_type     = "FARGATE" 
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.deployment-example-task.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.ip-tg.arn
    container_name   = "deployment-nextjs-container"
    container_port   = 80
  }
  network_configuration{
    subnets = [aws_subnet.public1.id,aws_subnet.public2.id]
    assign_public_ip = true
  }
}