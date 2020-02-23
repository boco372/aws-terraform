variable "region" {
    default = "eu-west-1"
}

provider "aws" {
    region  =   var.region
}

resource "aws_vpc" "myvpc" {
    cidr_block  =   "10.200.200.0/24"
    tags    =   {
        Name    =   "myvpc"
    }
}

resource "aws_internet_gateway" "myigw" {
    vpc_id      =   aws_vpc.myvpc.id
}

resource "aws_subnet" "public1" {
    vpc_id      =   aws_vpc.myvpc.id
    cidr_block  =   "10.200.200.0/28"
    availability_zone   =   "eu-west-1a"
    tags    =   {
        Name    =   "myfirstsubnet"
    }
}

resource "aws_security_group" "mysg" {
    vpc_id  =   aws_vpc.myvpc.id
    ingress {
        from_port   =   22
        to_port     =   22
        cidr_blocks =   ["0.0.0.0/0"]
        protocol    =   "tcp"
    }
    egress {
        from_port   =   80
        to_port     =   80
        cidr_blocks =   ["0.0.0.0/0"]
        protocol    =   "tcp"
    }
    egress {
        from_port   =   443
        to_port     =   443
        cidr_blocks =   ["0.0.0.0/0"]
        protocol    =   "tcp"
    }
}

resource "aws_spot_instance_request"  "myvm" {
    ami      =   "ami-099a8245f5daa82bf"
    spot_price  =   "0.005"
    instance_type   =   "t3.micro"
    subnet_id       =   aws_subnet.public1.id
    associate_public_ip_address     =   true
    key_name    =   "aws-ireland"
    security_groups     =   [aws_security_group.mysg.id]
    user_data           =   file("user_data.txt")
    iam_instance_profile    =   aws_iam_instance_profile.myProfile.name
    tags    =   {
        Name    =   "myvm"
    }
}

resource "aws_route_table" "myrt" {
    vpc_id      =   aws_vpc.myvpc.id
    route {
        cidr_block  =   "0.0.0.0/0"
        gateway_id  =   aws_internet_gateway.myigw.id
    }
    tags    =   {
        Name    =   "my_main_rt"
    }
}


resource "aws_route_table_association" "myrta" {
    route_table_id     =   aws_route_table.myrt.id
    subnet_id           =   aws_subnet.public1.id
}

output "instance_ip_addr" {
    value   =   aws_spot_instance_request.myvm.public_ip
    description =   "the public IP of the spot instance"
}

resource "null_resource" "add_ec2_tags" {
    provisioner "local-exec" {
        command = "aws ec2 create-tags --resources \"${aws_spot_instance_request.myvm.spot_instance_id}\" --tags Key=Name,Value=spot-vm --region=\"${var.region}\""
    }
}
#resource "aws_eip" "myeip" {
#    vpc     =   true
#}

#resource "aws_eip_association" "eip_assoc" {
#    instance_id     =   aws_spot_instance_request.myvm.spot_instance_id
#    allocation_id   =   aws_eip.myeip.id
#}

