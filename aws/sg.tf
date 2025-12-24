resource "aws_security_group" "ng1_sg" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "ng1_sg_ingress" {
  description       = "allow inbound traffic from private internal resources"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  security_group_id = aws_security_group.ng1_sg.id
  type              = "ingress"
  cidr_blocks = [
    "10.0.0.0/24"
  ]
}
