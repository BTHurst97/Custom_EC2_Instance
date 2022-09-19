# Custom_EC2_Instance
In the "Custom_EC2_and_VPC.tf" file you will find the steps that i followed too create a EC2 Instance with a custom VPC and Subnet that has ssh access with putty so we can make changes to it as well as setup a automatic web server to run on it so we can handle web traffic!

The steps i followed are as follows

#1. Create a VPC

#2. Create an Internet Gateway

#3. Create Custom Route Table

#4. Create a Subnet

#5. Associate that Subnet with our Route Table

#6. Create Security Group To Allow Port 22,80,443

#7. Create A network interface with an ip in the subnet that was created in step 4

#8. Assign an Elastic IP to the network interface

#.9 Create an Ubuntu Server


*Note that the region you choose in the provider "aws" section should be the region that is closest to you. or, you can follow along with what I have in my code however you will have to switch your region to us-west-1*

*All of this code can be found in the AWS Documentation and i Highly recommend taking a look if you are wanting to learn more (much like me).*

https://docs.aws.amazon.com/

just search terraform *whatever you want to learn* aws documentation.

*NOTE THAT YOUR SECRET KEY AND ACCESS KEY SHOULD BE THE KEYS FOR YOUR AWS ACCOUNT, THAT IS WHY MINE IS BLANK IN THIS TEXT*

Thanks for stopping by!


