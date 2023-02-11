output "name" {
  value = aws_lb.alb.name
}

output "dns_name" {
  value = aws_lb.alb.dns_name
}

output "target_group_arn" {
   value = aws_lb_target_group.group_target.arn
}