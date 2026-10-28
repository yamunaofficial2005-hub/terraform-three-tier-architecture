
# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create EC2 instances in private subnets
resource "aws_instance" "app" {
  count = 2

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id = var.private_subnet_ids[count.index]

  vpc_security_group_ids = [
    var.app_security_group_id
  ]

  associate_public_ip_address = false

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx
    systemctl enable nginx
    cat > /usr/share/nginx/html/index.html <<HTML
    <html>
      <body>
        <h1>Three Tier Architecture</h1>
        <h2>Application Server ${count.index + 1}</h2>
      </body>
    </html>
    HTML
    systemctl start nginx
  EOF

  tags = {
    Name = "${var.project_name}-app-${count.index + 1}"
    Tier = "application"
  }
}

# Register EC2 instances with ALB target group
resource "aws_lb_target_group_attachment" "app" {
  count = length(aws_instance.app)

  target_group_arn = var.target_group_arn
  target_id        = aws_instance.app[count.index].id
  port             = 80
}
