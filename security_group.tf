# Create a Security Group for fronend
resource "aws_security_group" "frontend-sg" {
  name   = "frontend-sg"
  vpc_id = aws_vpc.e2e-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]

  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment = "${var.environment_tag}"
  }
}

# Create a Security Group for Backend
resource "aws_security_group" "backend-sg" {
  name   = "backend-sg"
  vpc_id = aws_vpc.e2e-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment = "${var.environment_tag}"
  }
}