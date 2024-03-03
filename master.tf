resource "aws_instance" "foo" {
  ami                    = "ami-0cd59ecaf368e5ccf" # us-east-1 Ubuntu 20.04
  subnet_id              = aws_subnet.my_subnet.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.deployer.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]


  tags = {
    Name = "K8s-Master"
  }
}


resource "null_resource" "msetup" {
  depends_on = [aws_instance.foo]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    timeout     = "12m"
    host        = aws_instance.foo.public_ip
    private_key = file("./pkey")
  }
  provisioner "file" {
    source      = "./msetup.sh"
    destination = "/tmp/msetup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "/usr/bin/sudo /usr/bin/chmod +x /tmp/msetup.sh",
      "/usr/bin/sudo /tmp/msetup.sh"
    ]
  }
}
