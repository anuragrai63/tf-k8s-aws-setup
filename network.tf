resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-example22"
  }

}


resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "172.16.10.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "tf-example"
  }
}


resource "aws_internet_gateway" "my_ig" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MY_IGW"
  }
}

resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # All resources in public subnet are accessible from all internet.
    gateway_id = aws_internet_gateway.my_ig.id
  }

  tags = {
    Name = "Public-route"
  }
}

resource "aws_route_table_association" "my_rta" {
  route_table_id = aws_route_table.my_rt.id
  subnet_id      = aws_subnet.my_subnet.id
}

resource "aws_security_group" "my_sg" {
  name   = "my_sg"
  vpc_id = aws_vpc.my_vpc.id


  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_sg"
  }

}

