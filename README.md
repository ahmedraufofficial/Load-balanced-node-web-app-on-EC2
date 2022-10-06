# Load-balanced node web app on EC2
>Author: Ahmed Rauf

In this project we are using **Terraform** to create an AWS infrastructure and initializing a bash script on an **EC2 instance** to run multiple **Docker** containers behind a **web server** that takes care of load-balancing and TLS certificates

## Tooling

Computing and Open-source tools used in the project - 

 - AWS - Utilized VPC, Security Group, Routing tables, Elastic IP and EC2
 - Terraform - IAAC tool to create, change, and modify AWS resources
 - Git - Pull update code from git repo
 - Node.js - Run express.js with ejs to serve static html pages on dynamic routes 
 - Caddy - Web server with an automatic TLS for https (used instead of Nginx because certbot requires an existing domain name and I am using just the public IP)
 - Nip.io - Wildcard DNS for any IP address, which allows any IP address to be mapped on a hostname without a name 
 - Docker - PAAS for OS virtualization with containers running a Node.js web server
 

## Deployment Strategy

 1. Install Terraform on your OS
 2. Clone the existing [repository](https://github.com/ahmedraufofficial/terraform.git) on to your OS.
 3. Add a **variables.tf** file with existing **server** and **access** keys fetched from AWS.
 4. Run '**terraform plan**' in terminal to understand what all resources will be created, modified or deleted from AWS. 
 5. Run '**terraform apply**' in terminal to execute the actions proposed in terraform plan.
 6. Wait approximately a minute for instance to be launched and initialized (also because of sleep command in the bash script of instance)
 7. Terraform **outputs the public IP** of the instance. **Append .nip.io to the IP** and type it any address bar, which will redirect to the deployed web app.
 8. Visit the currently deployed web server - **[https://44.208.7.171.nip.io/](https://44.208.7.171.nip.io/)**
 9. Once the page is refreshed, Caddy web server will follow its **round robin - load balance** policy and thus forward the request to the other container.
