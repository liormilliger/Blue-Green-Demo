output "proxy_server_public_ip" {
  description = "The public IP address of the NGINX proxy server."
  value       = aws_instance.proxy_server.public_ip
}

output "blue_server_public_ip" {
  description = "The public IP address of the Blue server."
  value       = aws_instance.blue_server.public_ip
}

output "green_server_public_ip" {
  description = "The public IP address of the Green server."
  value       = aws_instance.green_server.public_ip
}
