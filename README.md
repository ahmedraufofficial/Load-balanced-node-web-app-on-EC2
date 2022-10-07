# Load-balanced node web app on EC2
>Author: Ahmed Rauf

In this project we are using **Terraform** to create an AWS infrastructure and initializing a bash script on an **EC2 instance** to run multiple **Docker** containers behind a **web server** that takes care of load-balancing and TLS certificates. I've introduced two types - 

 - **Type 1**: Executing Terraform manually from OS which follows the bash scripts within it's .tf file
 - **Type 2**: Running a job on Jenkins, which pulls the updated repository from Github, updates the web app on remote server and executes the .tf script in the pipeline.

## Tooling

Computing and Open-source tools used in the project - 

 - AWS - Utilized VPC, Security Group, Routing tables, Elastic IP and EC2
 - Terraform - IAAC tool to create, change, and modify AWS resources.
 - Git - Pull update code from Git repo.
 - Node.js - Run express.js with ejs to serve static html pages on dynamic routes.
 - Caddy - Web server with an automatic TLS for https (used instead of Nginx because certbot requires an existing domain name and I am using just the public IP).
 - Nip.io - Wildcard DNS for any IP address, which allows any IP address to be mapped on a hostname without a name.
 - Docker - PAAS for OS virtualization with containers running a Node.js web server.
 - Jenkins - Automation server to build, test and deploy software.
 
## Deployment Strategy
### Type 1 (Terraform + simple bash)
![Type 1](https://github.com/ahmedraufofficial/terraform/blob/main/images/type1.png?raw=true)
### Type 2 (Jenkins Pipeline + Terraform + bash)
![enter image description here](https://github.com/ahmedraufofficial/terraform/blob/main/images/type2.png?raw=true)

## How To Use
### Type 1
 1. Install Terraform on your OS
 2. Clone the existing [repository](https://github.com/ahmedraufofficial/terraform.git) on to your OS.
 3. Add a **variables.tf** file with existing **server** and **access** keys fetched from AWS.
 4. Run '**terraform plan**' in terminal to understand what all resources will be created, modified or deleted from AWS. 
 5. Run '**terraform apply**' in terminal to execute the actions proposed in terraform plan.
 6. Wait approximately a minute for instance to be launched and initialized (also because of sleep command in the bash script of instance)
 7. Terraform **outputs the public IP** of the instance. **Append .nip.io to the IP** and type it any address bar, which will redirect to the deployed web app.
 8. Visit the currently deployed web server - **[https://44.208.7.171.nip.io/](https://44.208.7.171.nip.io/)**
 9. Once the page is refreshed, Caddy web server will follow its **round robin - load balance** policy and thus forward the request to the other container.

### Type 2
 1. Go to [Jenkins URL](http://ec2-54-166-165-207.compute-1.amazonaws.com:8080/) .
 2. A user with read and build jobs only permissions has been created *username* - *test* and *password* - *test123* for testing purposes.
 3. Once signed in, check in **'Status'** to view all logs per stage in pipeline.
 4. We are also doing a **git pull** on the web app directory, and **re-adding the docker containers**.
 5. Same .tf file will be executed so downtime will be around 1 minute.
 6. Since we are running Jenkins on a differenct OS, another AWS instance will be created whose IP is **[https://3.209.230.120.nip.io/](https://3.209.230.120.nip.io/)**

## Bash & Jenkins Configurations
### Bash
 - Installing all packages (Docker & Caddy)
 - Cloning repository
 - Creating log files and Caddy's config file to reverse proxy and load balance
 - Starting Caddy
### Jenkins
 - Tool installation (Terraform)
 - Cloning repository
 - Initializing terraform
 - Applying terraform's plan to production
 - Updating web servers on remote server after a git pull

## Deployment Comparison
Both Type 1 and Type 2 execute the same terraform file, however in Type 2 we can update the terraform script, the web app and thus ease in the deployment while viewing logs at the same time. Moreover, we can create specific users with permissions to run jobs as well.

## Proposed Enhancements

 - Use Nginx (with a domain name) instead of Caddy as it's comparatively faster.
 - Split and architect the bash script added in user-data of Terraform's EC2 resource into a pipeline