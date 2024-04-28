# Graded-Assignment-on-Deploying-a-MERN-Application-on-AWS
Graded Assignment on Deploying a MERN Application on AWS


# Travel Memory

`.env` file to work with the backend:

```
MONGO_URI='ENTER_YOUR_URL'
PORT=3000
```

Data format to be added: 

```json
{
    "tripName": "Incredible India",
    "startDateOfJourney": "19-03-2022",
    "endDateOfJourney": "27-03-2022",
    "nameOfHotels":"Hotel Namaste, Backpackers Club",
    "placesVisited":"Delhi, Kolkata, Chennai, Mumbai",
    "totalCost": 800000,
    "tripType": "leisure",
    "experience": "Lorem Ipsum, Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum, ",
    "image": "https://t3.ftcdn.net/jpg/03/04/85/26/360_F_304852693_nSOn9KvUgafgvZ6wM0CNaULYUa7xXBkA.jpg",
    "shortDescription":"India is a wonderful country with rich culture and good people.",
    "featured": true
}
```

### Objective:

Gain practical experience in deploying a MERN stack application on AWS using infrastructure automation with Terraform and configuration management with Ansible.

Tasks:

### Part 1: Infrastructure Setup with Terraform

1. AWS Setup and Terraform Initialization:

   - Configure AWS CLI and authenticate with your AWS account.

   - Initialize a new Terraform project targeting AWS.

Solution:

- Created AWS user, that has necessary rights

- Navigated to IAM resource, pulled the user details > security credentials

- Created access keys, that can be used to configure aws

- Opened a bash terminal, run the below commands

```
aws configure

ENTER ACCESS KEY, SECRET ACCESS KEY, JSON, region - ap-south-1
```

- run aws sts get caller identity command to check if login configuration is setup correctly

```
aws sts get-caller-identity
```

A folder was created with name 'terraform-files' to store all terraform data

create main.tf file

```
provider "aws" {
    region = "ap-south-1"
}
```

Run below codes to test and initialize terraform

```
terraform init
terraform validate
terraform fmt
terraform plan
terraform apply
```

2. VPC and Network Configuration:

   - Create an AWS VPC with two subnets: one public and one private.

   - Set up an Internet Gateway and a NAT Gateway.

   - Configure route tables for both subnets.

Solution:

First created var.tf file, so that we can make the code reusable in future

```
defined region
defined vpc cidr block
defined public subnet cidr blocks
defined public subnet availability zone
defined private subnet cidr blocks
defined private subnet availability zone

```

Created main.tf file to write the code for IaC

defined vpc first

```
resource "aws_vpc" "assignment_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "assignment_vpc"
    }
}
```

defined public and private subnets

Defined internet gateway

EIP - to assciate with NAT gateway

and also defined NAT gateway

Later I have defined route tables
 so that we can defined traffic to be routed to gateways

Now defined route table association so that it can be attached to the public and private subnets

This completed our 2nd task

3. EC2 Instance Provisioning:

   - Launch two EC2 instances: one in the public subnet (for the web server) and another in the private subnet (for the database).

   - Ensure both instances are accessible via SSH (public instance only accessible from your IP).

4. Security Groups and IAM Roles:

   - Create necessary security groups for web and database servers.

   - Set up IAM roles for EC2 instances with required permissions.

Solution:

Added resource aws security group to the main.tf file

Added the ingress and egress rules

Made sure that the web server security group, egress has internet access and in ingress it has open ports at 80, and 22 from myIP

Made sure that the database server security group, egress has internet access and in ingress it has open ports at 22 from myIP - any resource within the vpc should be able access the database server.

Created a IAM role for ec2, gave full access in the role for all resources in AWS

Also created an instance profile, attached the role to the policy

Created ec2 instances for web server and also database server

5. Resource Output:

   - Output the public IP of the web server EC2 instance.

using output option in terraform, was able to output the public ip address for the web server and private ip for database server.

### This has completed our task one.
### screenshots attached for the deployment using terraform
-------------------------------------------------------------------------------

##### Part 2: Configuration and Deployment with Ansible

Solution:

1. Ansible Configuration:

   - Configure Ansible to communicate with the AWS EC2 instances.

-> Logged into aws console

Created an ec2 machine and installed anisble in it

Made sure that the ansible controller is inside the same vpc

Userdata - 

```
#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo apt install ansible git -y
```

2. Web Server Setup:

   - Write an Ansible playbook to install Node.js and NPM on the web server.

   - Clone the MERN application repository and install dependencies.

3. Database Server Setup:

   - Install and configure MongoDB on the database server using Ansible.

   - Secure the MongoDB instance and create necessary users and databases.

4. Application Deployment:

   - Configure environment variables and start the Node.js application.

   - Ensure the React frontend communicates with the Express backend.


Solution:

Created a directory to store the ansible files

```
mkdir ansible-files
```

Created inventory.ini to store the web-server and database ip addresses

```
vim inventory.ini

stored the below addresses as follows - 

[web_servers]
web_server ansible_host=43.205.243.63

[db_servers]
db_server ansible_host=10.0.2.200
```

Once this is done, created a yml file for the play book.

```
vim playbook.yml
```

Inside the playbook

- First define the hosts as web_servers

- Later become - yes, so that the commands can be run as sudo

- First task is to Install Node.js and NPM

- second Clone MERN application repository

- Changed the hosts now to database servers

- Later become - yes, so that the commands can be run as sudo

- We shall install the mongoDB

- mongoDB installtion was done using community edition documentation

### The environment variables are already defined inside the application folders, hence not mentioning them here, If needed additional tasks can be created to change the port and urls

- Changed the hosts back again to web_servers

- Later become - yes, so that the commands can be run as sudo

- the tasks is to simply run the backend and frontend nodeJS application.


----

SSH into ansible-controller

```
cd Graded-Assignment-on-Deploying-a-MERN-Application-on-AWS/ansible-files

vim ec2.pem

copy pasted the private key, so that the webservers database can be accessed using the keypair

chmod 700 ec2.pem
```

### FINALLY run

```
ansible-playbook playbook.yml -i inventory.ini --user ubuntu --key-file ./ec2.pem --verbose
```
Used --verbose to get detailed output
### This completes the entire project.

###### Thank you!!!
--------------------------------------------------------------------