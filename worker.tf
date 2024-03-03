resource "aws_instance" "bar" {
  ami                    = "ami-0cd59ecaf368e5ccf" # us-east-1 Ubuntu 20.04
  subnet_id              = aws_subnet.my_subnet.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.deployer.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
#  count                  = 2
  tags = {
    Name = "K8s-Worker"
  }

}



resource "null_resource" "wsetup" {
  depends_on = [aws_instance.bar]
#  count      = 2
  connection {
    type        = "ssh"
    user        = "ubuntu"
    timeout     = "15m"
#    host        = aws_instance.bar[count.index].public_ip
     host        = aws_instance.bar.public_ip
    private_key = file("./pkey")
  }
  provisioner "file" {
    source      = "./wsetup.sh"
    destination = "/tmp/wsetup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "/usr/bin/sudo /usr/bin/chmod +x /tmp/wsetup.sh",
      "/usr/bin/sudo /tmp/wsetup.sh"
    ]
  }
}


