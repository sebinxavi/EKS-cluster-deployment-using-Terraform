## Update the Project Details
#-------------------------------------


region = "us-east-1"
project = "sebin-vpceks-demoproject"
bucket = "terraform-state-bucket11"

### Updating the VPC Details
#-----------------------------------

vpc_cidr = "172.16.0.0/16"

public1_cidr = "172.16.0.0/19"
public2_cidr = "172.16.32.0/19"
public3_cidr = "172.16.64.0/19"
private1_cidr = "172.16.96.0/19"
private2_cidr = "172.16.128.0/19"
private3_cidr = "172.16.160.0/19"
public1_az = "us-east-1a"
public2_az = "us-east-1b"
public3_az = "us-east-1c"
private1_az = "us-east-1a"
private2_az = "us-east-1b"
private3_az = "us-east-1c"


## Update the EC2 Instance Details
#-------------------------------------
instance_type = "t3.micro"
ami = "ami-083654bd07b5da81d"
