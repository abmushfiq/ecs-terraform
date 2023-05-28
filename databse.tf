resource "aws_security_group" "db-sg-lab" {
  name = "db-sg-lab"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}

resource "aws_db_instance" "my_lab_postgresql" {

  engine                 = "postgres"
  identifier             = "mylabrdsinstance"
  allocated_storage      = 20
  engine_version         = "12.7"
  instance_class         = "db.t3.micro"
  username               = "myrdsuser"
  password               = "mypassword1234"
  vpc_security_group_ids = ["${aws_security_group.db-sg-lab.id}"]
  skip_final_snapshot    = true
  publicly_accessible    = true

}

output "sg-id" {
  value = aws_security_group.db-sg-lab.id
}

output "db-access-endpoint" {
  value = element(split(":", aws_db_instance.my_lab_postgresql.endpoint), 0)
}