
# Identity E2E project

![alt text](https://github.com/ubesinghe/identity-e2e/blob/master/architect_diagram/three-tier-architecture.png)

 
I have used AWS public cloud to provision the necessary infrastructure resources. AWS cloud is an easily accessible and maintainable cloud provider.
 
According to the requirements of this project, it requires a 3-tier architecture. I have chosen aws cloud to deploy the application. Therefore I propose the architect to maintain the application status with high availability ( Please refer to the diagram above).
 
With this three tier architecture, an application which comprises Frontend, Backend and a DB is provisioned. The application (frontend and backend) is deployed in two availability zones to increase the availability and DynamoDB (AWS managed DB) acts as the non relational database(NoSQL DB). 
 
Since frontend is the publicly accessible component of the application, it is provisioned in the public subnet and backend is not exposed publicly, hence it is provisioned in a private subnet. 
 
Security groups are used in a way that only the backend of the application can access the database. An Internal Application Load Balancer (ALB) is used for the internal communication of the backend application and is not exposed to the public. It would be only accessible by the frontend application servers. 
 
Provisioning of all the AWS resources are conducted through Infrastructure as a Code (IaC) using HashiCorp Terraform (TF). The reason to use IaC is to eliminate/minimize any human errors of the manual intervention if this setup is required to be repeated.
 
IaC enabled a consistent workflow to safely and efficiently provision and manage the infrastructure throughout its lifecycle. In order to maintain the Iac in a version controlled repository, the TF code is maintained in the GitHub repository. And the TF state file is being maintained in the S3 bucket.
 
In order to cater the user  demand and to get maximum cost benefits of the AWS cloud, Auto scaling has been introduced in this architecture.
 
Launch configurations have been used to run EC2 instances via Auto scaling groups. Launch configurations contain the Amazon Machine Images, Instance type, key pair, security groups and User data. 
 
The reason behind using a docker container is that it is a portable computing environment. It contains everything an application needs to run. Unlike a VM, which relies on a virtualized operating system and a hypervisor software layer, containerization offers applications direct access to computing resources without extra software layers. Containerization also allows for improved security and easier management. 


## DynamoDB table
 
I have created a DynamoDB table using the following document. DB was created using AWS CLI. This can be implemented using Terraform or any automation tools. This is connected to AWS resources using DynamoDB IAM policies.
 
https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/getting-started-step-1.html
 
```
aws dynamodb create-table \
   --table-name UserCheckin \
   --attribute-definitions \
       AttributeName=Username,AttributeType=S \
   --key-schema \
       AttributeName=Username,KeyType=HASH \
   --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
   --region eu-west-2
```

## How to install docker in amazon linux2 EC2 Instance
https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html

``` 
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
docker info
``` 
 
## Installing other necessary packages.

```
sudo yum install git -y
sudo yum install telnet -y
```
 
## Get the "Dockerfile" from github repo, build/run the docker image.
 
###### Docker build/run for frontend service 
```
git clone git@github.com:ubesinghe/e2e-frontend-app.git
 
cd e2e-frontend-app/
 
docker build -t fronted-app:1.0 . 

docker images

docker run -d -p 80:8080 frontend-app:1.0
```
###### Docker build/run for backend service

```
git clone git@github.com:ubesinghe/e2e-backend-app.git
 
cd e2e-backend-app/
 
docker build -t backend-app:1.0 . 

docker images

docker run -d -p 80:8080 backend-app:1.0
```

## To verify the connectivity between frontend docker and backend load balancer 
 
```
telnet internal-backend-lb-1214632732.eu-west-2.elb.amazonaws.com 5000

curl internal-backend-lb-1214632732.eu-west-2.elb.amazonaws.com:5000/api/v1/get
```

## Enabeling the communication in between frontend and backend services

Configure the frontend microservice to send traffic to the backend microservice therefore we need to get the backend interal load balancer to expose to the frontend service.

BACKEND_URL environment variable has been set as a key/value in the frontend docker run.

``` 
docker run -d -p 80:8080 -e BACKEND_URL='http://internal-backend-lb-1214632732.eu-west-2.elb.amazonaws.com:5000/' frontend-app:1.0
 
docker exec -it 137b45de8848 bash

env | grep BACKEND_URL
``` 
However, this should be automated as a further enhancement.

## Possible Optimizations and Learnings of the exercise.
 
Some of the configurations are managed through the user data. However, Ansible is the best option for application related configuration management.

Use CI/CD tools such as Jenkins or Gitlab. This enables environment based code promotion and infra provisioning.