# Nextjs application deployed with terraform to AWS ECS using Bluee/Green deployment with Github Actions as CI/CD
### Description of this project
Infrastructure as code is presented as terraform and resources such as ECS cluster with task definition, service, loadbalancer, CodeDeploy
Pipeline is developed with Github Actions and is triggered on every push.
Pipeline first builds a new image from Dockerfile and pushes it to ECR repository.
Application is beeing built in Github Actions.
Task definitions gets overwritten with the new latest image.
Application then gets deployed to ECS service true CodeDeploy using Blue/Green deployment.
Blue Green is set to linear deploy 20% of traffic every 2 minutes to Green environment.
Loadbalancer gets new target groups and is now serving new application on DNS link.

## Nextjs application is forked
Forked js application form: https://github.com/stuartmackenzie/nextjs-single-page-template

### Deploy Nextjs application in AWS ECS cluster using Github actions to build and CodeDeploy to deploy app

Github repository: https://github.com/lukaevet/aws-ecs-blue-green-terraform

#### Prerequire

Setup aws local paramenetrs in terminal.
Build, tag and push Docker image from Dockerfile to ECR repository called `nextjs-application`.
Install terraform in your local environment and start to deploy resources.

### Upload terraform infrastructure to AWS

Command `terraform plan` will make a visual representation of resources that will be deployed.
Command `terraform apply` will deploy those resources to AWS.

### Github actions
Next add everything and push it to our Github repository. 
Add secrets in your Github: Settings/Actions/secrets for AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION.

Github actions workflow ref: https://github.com/lukaevet/aws-ecs-blue-green-terraform/actions
Every time release is beeing made in your repository Github actions will be triggered and it will login to your AWS account and it will build, push and deploy nextjs application to your ECR image.
Task definition with ECR will be deployed to ECS cluster and updated version of the application will be deployed.
