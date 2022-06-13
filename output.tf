output "lb_url" {
  description = "URL of load balancer"
  value       = "http://${aws_lb.backend-lb.dns_name}/"

}