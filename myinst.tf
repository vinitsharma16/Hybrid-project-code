provider "aws" {
  region = "ap-south-1"
  profile = "myprofile"
}


resource "aws_instance" "inst" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name = "mykey"
  security_groups = [ "launch-wizard-2" ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/vinit/Downloads/mykey.ppk")
    host     = aws_instance.inst.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }

  tags = {
    Name = "vinitos"
  }

}


resource "aws_ebs_volume" "esb1" {
  availability_zone = aws_instance.inst.availability_zone
  size              = 1
  tags = {
    Name = "vinitstg"
  }
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.esb1.id}"
  instance_id = "${aws_instance.inst.id}"
  force_detach = true
}


output "myos_ip" {
  value = aws_instance.inst.public_ip
}


resource "null_resource" "null1"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.inst.public_ip} > publicip.txt"
  	}
}



resource "null_resource" "null2"  {

depends_on = [
    aws_volume_attachment.ebs_att,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/vinit/Downloads/mykey.ppk")
    host     = aws_instance.inst.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/vinitsharma16/Hybrid_project.git /var/www/html/"
    ]
  }
}



resource "null_resource" "null3"  {


depends_on = [
    null_resource.null2,
  ]

	provisioner "local-exec" {
	    command = "chrome  ${aws_instance.inst.public_ip}"
  	}
}


