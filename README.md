## NextJs application is forked
Forked js application form: https://github.com/stuartmackenzie/nextjs-single-page-template


### Deploy Nextjs application in AWS ECS cluster using Github actions

Github repository: https://github.com/lukaevet/aws-ecs-nextjs-app-actions

#### Automate Docker container deployment to AWS ECS using CloudFormation

Ref: https://gcore.com/blog/automate-docker-container-deployment-to-aws-ecs-using-cloudformation/

Upload CloudFormation stack called `infrastructure.yaml` to AWS named for example: `ecs-nextjs-app`
Build, tag and push docker image to AWS ECR with name `nextjs-application`.  

### Prepre for Automation

Go to task definition and find the latest revision and copu the json file that has been created.
Paste the content of the file into root of the directory and name it `task-definition.json`.

### Github actions
Next add everything and push it to our Github repository. 
 Add secrets in your Github: Settings/Actions/secrets for AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION.

Github actions workflow ref: https://github.com/marketplace/actions/aws-ecr-eks
Every time someone pushes code to your repository Github actions will be triggered and it will login to your AWS account and it will build, push and deploy nextjs application to your ECR image.
Task definition with ECR will be deployed to ECS cluster and uspated version of the application will be deployed.