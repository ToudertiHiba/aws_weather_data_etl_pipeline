provider "aws" {
  region = var.aws_region
  access_key = jsondecode(file("access_keys.json")).ACCESS_KEY
  secret_key = jsondecode(file("access_keys.json")).SECRET_ACCESS_KEY
}

# Create a new VPC
resource "aws_vpc" "sdtd_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name = "SDTD_VPC"
  }
}


# Create a subnet within the VPC
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.sdtd_vpc.id
  cidr_block              = "10.0.1.0/24"

  tags = {
    Name = "SDTD_Main_Subnet"
  }
}


# Create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.sdtd_vpc.id

  tags = {
    Name = "SDTD_Main_Internet_Gateway"
  }
}

# create a route table and associate it with the subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.sdtd_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  
  tags = {
    Name = "SDTD_Main_Route_Table"
  }
}

resource "aws_route_table_association" "my_subnet_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# VPC
resource "aws_security_group" "allow_http_https_ssh" {
  name        = "allow_http_https_ssh"
  description = "Allow HTTP, HTTPS, and SSH traffic"
  vpc_id = aws_vpc.sdtd_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "allow_http_https_ssh"
  }
}

resource "aws_security_group" "allow_9092" {
  name        = "allow_9092"
  description = "Allow incoming traffic on port 9092"
  vpc_id = aws_vpc.sdtd_vpc.id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_9092"
  }
}

resource "aws_security_group" "allow_9042" {
  name        = "allow_9042"
  description = "Allow incoming traffic on port 9042"
  vpc_id = aws_vpc.sdtd_vpc.id

  ingress {
    from_port   = 9042
    to_port     = 9042
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 9042
    to_port     = 9042
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_9042"
  }
}

resource "aws_security_group" "allow_8501" {
  name        = "allow_8501"
  description = "Allow incoming traffic on port 8501"
  vpc_id = aws_vpc.sdtd_vpc.id

  ingress {
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_8501"
  }
}


resource "aws_key_pair" "aws_ec2_rsa_key" {
  key_name   = "aws_ec2_rsa_key"
  public_key  = file("aws_ec2_rsa_key.pub")
}

# VMs
resource "aws_instance" "vm_kafka" {
  ami           = var.ubuntu20_ami_id
  instance_type = var.instance_type
  key_name = aws_key_pair.aws_ec2_rsa_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_http_https_ssh.id, aws_security_group.allow_9092.id]
  subnet_id       = aws_subnet.my_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "vm-kafka"
  }
}

resource "aws_instance" "vm_spark" {
  ami           = var.ubuntu20_ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.aws_ec2_rsa_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_http_https_ssh.id]
  subnet_id       = aws_subnet.my_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "vm-spark"
  }
}

resource "aws_instance" "vm_cassandra" {
  ami           = var.ubuntu20_ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.aws_ec2_rsa_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_http_https_ssh.id, aws_security_group.allow_9042.id]
  subnet_id       = aws_subnet.my_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "vm-cassandra"
  }
}

resource "aws_instance" "vm_streamlit_visualisation" {
  ami           = var.ubuntu20_ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.aws_ec2_rsa_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_http_https_ssh.id, aws_security_group.allow_8501.id]
  subnet_id       = aws_subnet.my_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "vm-streamlit-visualisation"
  }
}

# Inventory file
resource "local_file" "inventory" {
  content  = <<EOF
[kafka_vm]
${aws_instance.vm_kafka.public_ip}

[spark_vm]
${aws_instance.vm_spark.public_ip}

[cassandra_vm]
${aws_instance.vm_cassandra.public_ip}

[streamlit_visualisation_vm]
${aws_instance.vm_streamlit_visualisation.public_ip}
    EOF
  filename = "inventory.ini"
}