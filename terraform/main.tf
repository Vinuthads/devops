# -------------------------
# VPC
# -------------------------

resource "aws_vpc" "main" {

  cidr_block = "10.0.0.0/16"

  enable_dns_support = true

  enable_dns_hostnames = true


  tags = {
    Name = "${var.project_name}-vpc"
  }
}



# -------------------------
# Public Subnet
# -------------------------

resource "aws_subnet" "public" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.1.0/24"


  availability_zone = "${var.aws_region}a"


  # Automatically assign public IPv4

  map_public_ip_on_launch = true


  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}



# -------------------------
# Internet Gateway
# -------------------------

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main.id


  tags = {
    Name = "${var.project_name}-igw"
  }
}



# -------------------------
# Public Route Table
# -------------------------

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id


  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id

  }


  tags = {
    Name = "${var.project_name}-public-route"
  }

}



resource "aws_route_table_association" "public" {

  subnet_id = aws_subnet.public.id

  route_table_id = aws_route_table.public.id

}



# -------------------------
# Security Group
# -------------------------

resource "aws_security_group" "web" {


  name = "${var.project_name}-security-group"


  vpc_id = aws_vpc.main.id



  # SSH access

  ingress {

    description = "SSH"

    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }



  # HTTP

  ingress {

    description = "HTTP"

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }



  # HTTPS

  ingress {

    description = "HTTPS"

    from_port = 443

    to_port = 443

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }



  
  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }



  tags = {

    Name = "${var.project_name}-sg"

  }

}



# -------------------------
# EC2 Instance
# -------------------------

resource "aws_instance" "server" {

  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  key_name = var.key_name

  user_data = <<-EOF
#!/bin/bash
set -eux

export DEBIAN_FRONTEND=noninteractive

apt-get update -y

apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    git

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y

apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

docker --version
docker compose version
EOF

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-server"
  }
}
# -------------------------
# Route53 settings
# -------------------------

data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "app_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.record_name
  type    = "A"
  ttl     = 300
  records = [aws_instance.server.public_ip]
}
