#!/bin/bash

### PRE REQ for ANSIBLE ##
pip install ansible ||true

APP_NAME=php-process-csv
DOCKER_REPO=ecrorwhatever
export APP_VERSION=${BUILD_NUMBER}
export VAULTPASSWORD=$JENKINS_STORED_PWD
echo $VAULTPASSWORD > /tmp/vault_pwd.txt


echo "Generating php config files with parameters"
cd ansible
ansible-playbook -e target=localhost generate.yml --vault-password-file /tmp/vault_pwd.txt
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi


echo "Preparing for Image Creation"
cd ../
cp -f *.php ./Docker/src/
cp -R vendor/ ./Docker/src/
cp -R templates/ ./Docker/src/ 


echo "Creating Image"
cd ./Docker
docker build -t $DOCKER_REPO/$APP_NAME:$APP_VERSION .
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

docker push $DOCKER_REPO/$APP_NAME:$APP_VERSION

### DEPLOY THE APPlICATION ON KUBERNETES ## only run for first time

kubectl run php-process-csv --replicas=2 --labels="run=load-balanced" --image=$DOCKER_REPO/$APP_NAME:$APP_VERSION  --port=80
kubectl expose deployment php-process-csv --type=LoadBalancer --name=php-process-csv-service


#### UPDATE APPLICATION ###

kubectl set image deployment/php-process-csv php-process-csv=$APP_NAME:$APP_VERSION
### GET STATUS ####
kubectl rollout status deployment/php-process-csv


