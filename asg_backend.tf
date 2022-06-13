## Creating Launch Configuration
resource "aws_launch_configuration" "backend_launch_config" {
  image_id               = var.instance_ami
  instance_type          = "t2.micro"
  security_groups        = ["${aws_security_group.backend-sg.id}"]
  iam_instance_profile   = aws_iam_instance_profile.e2e_instance_profile.name
  key_name               = aws_key_pair.ec2key.key_name
  user_data = <<-EOF
              #!/bin/bash
  echo "Copying the Private SSH Key to the server"

  sudo yum update -y
  sudo amazon-linux-extras install docker -y
  sudo service docker start
  sudo usermod -a -G docker ec2-user
  sudo yum install git -y
  sudo touch ~/.ssh/id_rsa
echo "-----BEGIN OPENSSH PRIVATE KEY-----
xxxxxx
xxxxxx
-----END OPENSSH PRIVATE KEY-----" > ~/.ssh/id_rsa

  sudo touch ~/.ssh/config

  echo "Host github.com" >> ~/.ssh/config
  echo "  StrictHostKeyChecking no" >> ~/.ssh/config
  sudo chmod 400 ~/.ssh/id_rsa
  sudo ssh-add ~/.ssh/id_rsa
  ssh-agent bash -c 'ssh-add ~/.ssh/id_rsa; git clone git@github.com:ubesinghe/e2e-backend-app.git'
  cd e2e-backend-app
  sudo docker build -t backend-app:1.0 .
  sudo docker run -d -p 5000:5000 backend-app:1.0

  EOF
  lifecycle {
    create_before_destroy = false
  }

}
/*
resource "aws_key_pair" "ec2key" {
  key_name   = "publicKey"
  public_key = file(var.public_key_path)
}
*/

## Creating AutoScaling Group
resource "aws_autoscaling_group" "backend-asg" {
  name                       = "backend_asg"
  launch_configuration       = "${aws_launch_configuration.backend_launch_config.id}"
  desired_capacity           = 2
  min_size                   = 2
  max_size                   = 2
  vpc_zone_identifier        = [aws_subnet.e2e_backend_a.id, aws_subnet.e2e_backend_b.id]
  health_check_type          = "ELB"
  target_group_arns          = [aws_lb_target_group.backend_tg.arn]
  tag {
    key = "Name"
    value = "e2e-backend"
    propagate_at_launch = true
  }
}


resource "aws_lb" "backend-lb" {
  name               = "backend-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.backend-sg.id]
  subnets            = [aws_subnet.e2e_backend_a.id, aws_subnet.e2e_backend_b.id]

  enable_deletion_protection = false

  tags = {
    Environment = "fronend-lb"
  }
}


resource "aws_lb_target_group" "backend_tg" {
  name        = "backend"
  port        = 5000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.e2e-vpc.id
}

resource "aws_lb_listener" "backend_listner" {
  load_balancer_arn = aws_lb.backend-lb.arn
  port              = 5000
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.id
  }
}