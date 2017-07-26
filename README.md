# php-process-csv
## The parser web application: 
- The application is written in php using a micro framework (Slim framework). Its basically put together using some examples already floating on github. 
- The application requires a mysql database and an s3 bucket to store the processed files. 
- First page shows the list of processed files from the database (only the names) and there is an interactive upload function which uploads the csv files , save it on s3 bucket and process it and store contents on the db. 

## Kubernetes Cluster: 

- In order to create the kubernetes cluster on aws , following are the steps/requirements

Step 1) Create a private dns hosted zone on AWS 
```
aws route53 create-hosted-zone --name k8hj.local --hosted-zone-config Comment=privateonlyzone,PrivateZone=true
```
Step 2) Create an s3 bucket for storing the kubernetes data
```
aws s3api create-bucket --bucket k8buckethj --region ap-southeast-1 --create-bucket-configuration LocationConstraint=ap-southeast-1
```
Step 3) Using the tool "kops" the cluster with one master and two nodes (multi AZ) can be created: 
configure your aws credentials with aws configure
```
 export KOPS_STATE_STORE=s3://k8buckethj
 export NAME=myfirstcluster.k8hj.local
 kops create cluster --zones ap-southeast-1a --dns private ${NAME}
 kops update cluster ${NAME} --yes
 kops validate cluster
 ### Make sure the master node is accessible via host file 
 ### Edit the /etc/hosts file and add the entry 
 ### <public ip of the master node> api.myfirstcluster.k8hj.local
 ### Verify the cluster is up and running after few minutes
 kubectl get nodes
```
## Highly Available Database (RDS Multi Zone enabled MySql)
- Once the kubernetes cluster has created the complete infrastructure with dedicated VPC and subnets then the RDS needs to be created using the same VPC/Subnets. 
- AWS RDS gui wizard can be used to create a multi AZ RDS instance ( a template will be included in the repository) which is accessible by the same subnet that kubernetes cluster is running on 
- db_migration_first_run.sql has been provided in the repository to be run when the db is created which creates the required tables for the application.

## GitLab
- Different blogs/posts are available to setup local gitlab instance on kubernetes. Following blog has been quite helpful and straightforward 
```
http://blog.lwolf.org/post/how-to-easily-deploy-gitlab-on-kubernetes/
```

## CI/CD Pipeline

- Any tool for example Jenkins/TeamCity/CodePipeline can be used to setup a simple job that is automatically kicked off as soon as we have a merge in the master branch of the repository
- The script jenkins_shell.sh provides a simple flow of commands that will create a dockerised image of the application and then deploy it to kubernetes with an updated tag using CI tool build number as a reference point.
- The flow first generates the required configuration of the app by running ansible locally. (the files ansible/group_vars/*.yml should be updated with the required info, eg db name , db end point , db pwd ,s3 bucket etc). The secrets have been saved using ansible-vault and can be decrypted using the password "simple". Once the configuration has been generated then docker build runs to create the ready to use image for application


## To Do 

- Setup Cloudfront infront of the external service ELB for caching the appliction and have multi home. 
- Setup Jenkins/TeamCity to automate the deployment flow , being kicked off every time there is a merge in master branch. 
- Add action buttons for each processed files in the app 
