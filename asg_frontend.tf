## Creating Launch Configuration
resource "aws_launch_configuration" "frontend_launch_config" {
  image_id               = var.instance_ami
  instance_type          = "t2.micro"
  security_groups        = ["${aws_security_group.frontend-sg.id}"]
  iam_instance_profile   = aws_iam_instance_profile.e2e_instance_profile.name
  key_name               = aws_key_pair.ec2key.key_name
  user_data = <<-EOF
              #!/bin/bash
  echo "Copying the private SSH Key to the server"

  sudo yum update -y
  sudo amazon-linux-extras install docker -y
  sudo service docker start
  sudo usermod -a -G docker ec2-user
  sudo yum install git -y
  sudo touch ~/.ssh/id_rsa
echo "-----BEGIN OPENSSH PRIVATE KEY-----
xxxxx
xxxxx
-----END OPENSSH PRIVATE KEY-----" > ~/.ssh/id_rsa

  sudo touch ~/.ssh/config

  echo "Host github.com" >> ~/.ssh/config
  echo "  StrictHostKeyChecking no" >> ~/.ssh/config
  sudo chmod 400 ~/.ssh/id_rsa
  sudo ssh-add ~/.ssh/id_rsa
  ssh-agent bash -c 'ssh-add ~/.ssh/id_rsa; git clone git@github.com:ubesinghe/e2e-frontend-app.git'
  cd e2e-frontend-app
  sudo docker build -t frontend-app:1.0 .
  sudo docker run -d -p 80:8080 -e BACKEND_URL='http://internal-backend-lb-1060170039.eu-west-2.elb.amazonaws.com:5000/' frontend-app:1.0

  EOF
  lifecycle {
    create_before_destroy = true
  }
}

## Creating AutoScaling Group
resource "aws_autoscaling_group" "frontend-asg" {
  name                       = "frontend_asg"
  launch_configuration       = "${aws_launch_configuration.frontend_launch_config.id}"
  desired_capacity           = 2
  min_size                   = 2
  max_size                   = 2
 # load_balancers             = [aws_lb.frontend-lb.id]
  vpc_zone_identifier        = [aws_subnet.e2e_frontend_a.id, aws_subnet.e2e_frontend_b.id]
  health_check_type          = "ELB"
  target_group_arns          = [aws_lb_target_group.frontend_tg.arn]
  tag {
    key = "Name"
    value = "e2e-frontend"
    propagate_at_launch = true
  }
}


resource "aws_lb" "frontend-lb" {
  name               = "frontend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend-sg.id]
  subnets            = [aws_subnet.e2e_frontend_a.id, aws_subnet.e2e_frontend_b.id]

  enable_deletion_protection = false

  tags = {
    Environment = "fronend-lb"
  }
}


resource "aws_lb_target_group" "frontend_tg" {
  name        = "frontend"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.e2e-vpc.id
}

resource "aws_lb_listener" "frontend_listner" {
  load_balancer_arn = aws_lb.frontend-lb.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.id
  }
}