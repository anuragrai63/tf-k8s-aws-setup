resource "aws_instance" "foo" {
  ami                    = "ami-0cd59ecaf368e5ccf" # us-east-1 Ubuntu 20.04
  subnet_id              = aws_subnet.my_subnet.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.deployer.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]

connection {
    type     = "ssh"
    user     = "ubuntu"  # Replace with your actual username
    private_key = "${file("/root/tf-k8s-aws-setup/pkey")}"  # Replace with your SSH private key
    host = self.public_ip
    script_path = "/tmp/tf-k8s-aws-setup/msetup.sh"
  }

  provisioner "remote-exec" {
    script = "/root/tf-k8s-aws-setup/msetup.sh"
    # Path to your local shell script, relative or absolute
   # inline = [
    #  "/root/tf-k8s-aws-setup/msetup.sh"
    #]
  }

  tags = {
    Name = "K8s-Master"
  }
}
resource "aws_instance" "bar" {
  ami                    = "ami-0cd59ecaf368e5ccf" # us-east-1 Ubuntu 20.04
  subnet_id              = aws_subnet.my_subnet.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.deployer.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  count                  = 2
  tags = {
    Name = "K8s-Worker"
  }

}

resource "aws_key_pair" "deployer" {
  key_name   = "k8s"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCmjxB3dN3OtcSVcSQpuE3UXmD1q+vRvN069Ct/MzcDW5cQjJUX2JIxZt1T4ZX0bdmM6p6+dtsNY/LOug6WJj2WlDty0XbPr0MH1bVZu8CtRNLE6UduvdW8cn+J2lsh3ObSTOMg7uF9Erz11vq8hyu4bOaOuL8WDFYh9wKzaicaHs9vYPv71U0MnxUT6vTFAD0+e/L873oAoW8kX2CeLFXNcoPt4ByVIQer8x0qkGkvNeHCF62iuWb/Aqz1qBUBAeuttiU2pFeuSF6F6x64RrmXeRrKS8T+reNG8/l7hIr2q9aEVWYlmq6kD1SBrHEaTzlz2Fr9k23R0xArJGZ4mKqkAWc8yfT6ZNA4jKAEy0DIbyqoGNmd7/E6lc5Hxt7fuxoQKC6N0jEIshGHlRQqJ6z377BvGygPESbOq4IBdVF+ihQa1IjAA5H9wXKUd342NWClIe34ecLv63HyLv4rMMh9dDKBYJbmfBVizgZeySGD+ksGNMpL8BCvix6H71/LD98= root@ip-172-31-18-12.ec2.internal"
}
