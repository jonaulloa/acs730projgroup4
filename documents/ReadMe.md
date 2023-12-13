## ACS730 NAA Final Project: Automating a Two-Tier Web Application with Terraform Group 4 

# Overview 

  • The aim of this project is to show how to automate a two-tier web application using Terraform. 

  • We create an infrastructure architecture on AWS to host our website on all the instances across different environments with various configurations. 

  • This project implementation also shows the use of modules and github actions. 


## The Roadmap is divided into 2 Sections
  Exploring the code base and setting up the Prerequisites 

  1.	Clone the repository and Explore the branches 
  > git clone git@github.com:jonaulloa/acs730projgroup4.git 

   Note: The clone command is SSH based, so make sure that SSH key is added in your environment.

• After setting up the local repository, navigate to the branch you want to work on (dev is preferred) using 
> git checkout [branch-name]

• The repository has two main branches: 'prod' and 'staging.' 'prod' serves as the primary branch for the repository. Development changes are made in the staging branch and subsequently merged into the 'prod' branch.  

    2.	Understanding the Code Base Structure 
The code base has the following structure.

    2.1	environments 
    Final_Test/
      |-- modules/
      |   |-- aws_network/
      |   |-- aws_webserver/
      |-- Prod/
      |   |-- network/
      |   |-- webservers/

    2.2	images
    • The environments folder is the root folder that contains the configuration for each of the prod environment. It depends on the aws_network and aws_webservers modules present in the modules folder for the networking and webserver configurations.

    • The networking part defines the configuration related to the network of the architecture which includes the VPC, subnets and the network gateways. 

    • The webserver folder defines the configuration related to the load balancer, server template, auto scaling group, user data and the security groups.
    
    • Lastly, the images folder has the images that need to be uploaded to the S3 bucket which will be accessed by the webservers to display the webpage.

3.	Generating SSH Keys 

  In all the webserver folders of the environments root folder, SSH keys need to be generated which will be used for deploying infrastructure. The naming convention to be followed is “Final_Test”. 

  To generate SSH key use the command below, 

    ssh-keygen -t rsa -f Final_Test


# Deploying S3 bucket 

 > On the AWS management console create S3 buckets for the Prod environment. This bucket will store the tfstate for the Prod environments and the images to be shown on the webpage. The bucket should have the images folder in the git uploaded to it. 

  Note: If there is a bucket already existing with the names given above choose a different name and do the necessary changes in config.tf files and in main.tf for webserver where the terraform remote state file is accessed. 

# Deploying Infrastructure 
To Deploy the infrastructure in the environments we shall use the terraform commands. Firstly, we set the alias by 
>alias tf=terraform. 

Then navigate to the environment based on the configuration you want to deploy.
Follow the commands below to deploy the infrastructure in Prod folder. The commands need to be followed assuming that the working directory is Final_Test.
  > cd environments/prod/networking

  > tf init

  > tf fmt

  > tf validate

  > tf plan

  > tf apply --auto-approve
  
# After the deployment of networking infrastructure
> cd ../webserver

> tf init

>tf fmt

>tf validate

>tf plan

>tf apply --auto-approve



Access the private webserver via Bastion 
The admins can only reach the private web servers through SSH by using the Bastion Server. To do this, connect to Bastion server via SSH with its public ip and ssh-key through the command below.
> ssh -i <private-ssh-key> ec2-user@<bastion-public-IP> 

Then, inside the Bastion server, obtain the SSH Key for the private webserver and use the following command to access the machine. 

> ssh -i <private-ssh-key> ec2-user@<webserver-private-IP> 


# Delete the Infrastructure 

Deletion of resources should follow a certain order to ensure proper deletion. The webserver components should be removed before the networking part. This is crucial because if we try to delete networking before webserver, some components will not be removed and will time out since the webserver components are still connected to the network components. Follow the steps below to destroy the infrastructure.
> cd environments/prod/webserver

> tf destroy --auto-approve
  
  # After the deletion of webserver infrastructure
  > cd ../networking
  
  > tf destroy --auto-approve





Group 4: 
> Camantes, Rose Ann

> Concepcion, Michael

> Ramos Daphne Denise

>	Ulloa, Jonalyn

>Opoku Junior Antwi, Augustine


