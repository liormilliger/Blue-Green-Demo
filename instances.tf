resource "aws_instance" "blue_server" {
  ami           = var.aws_ami
  instance_type = var.instance_type
  user_data     = file("${path.module}/user-data-blue.sh")
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "Blue-Server"
    Deployment = "Blue"
  }
}

resource "aws_instance" "green_server" {
  ami           = var.aws_ami
  instance_type = var.instance_type
  user_data     = file("${path.module}/user-data-green.sh")
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "Green-Server"
    Deployment = "Green"
  }
}

resource "aws_instance" "proxy_server" {
  ami           = var.aws_ami
  instance_type = var.instance_type
  user_data = templatefile("${path.module}/user-data-proxy.sh", {
    blue_ip  = aws_instance.blue_server.private_ip,
    green_ip = aws_instance.green_server.private_ip
  })
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "NGINX-Proxy-Server"
  }
}
