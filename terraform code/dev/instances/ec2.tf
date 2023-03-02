data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}


resource "aws_instance" "k8s" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.medium"

  root_block_device {
    volume_size = 16
  }

  vpc_security_group_ids = [
    module.ec2_sg.security_group_id,
    module.dev_ssh_sg.security_group_id
  ]
  iam_instance_profile = "LabInstanceProfile"
  user_data            = file("${path.module}/init_kind.sh")
  
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    project = "clo835"
  }

  key_name                = "week5"
  monitoring              = true
  disable_api_termination = false
  ebs_optimized           = true
}

resource "aws_key_pair" "k8s" {
  key_name   = "week5"
  public_key = file("${path.module}/week5.pub")
}


resource "aws_ecr_repository" "ecr" {
  name                 = "appecr"
  #force_delete         = true
  encryption_configuration {
    encryption_type = var.encrypt_type
  }
  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecr_repository" "db" {
  name                 = "dbecr"
  #force_delete         = true
  encryption_configuration {
    encryption_type = var.encrypt_type
  }
  image_scanning_configuration {
    scan_on_push = true
  }
}
