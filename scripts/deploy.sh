#!/bin/bash -x
set -e

### Finding the git branch and setting up the image tag ###

GIT_BRANCH=$(echo $GIT_SOURCE| awk -F "/" '{ print $3 }')


if [[ $GIT_BRANCH == 'master' ]]; then export IMAGE_TAG="$BUILD_ID-rc"
elif [[ $GIT_BRANCH == 'develop' ]]; then export IMAGE_TAG="$BUILD_ID-dev"
else
  echo "Valid git branches for deployment->>> master, develop"
  exit 1
fi



#### Azure login for the deployment ###

az login --service-principal -u $SVC_PRINCIPAL_ID -p $SVC_PRINCIPAL_PASSWORD --tenant $TENANT_ID
KUBE_DIR=azure-devops/manifest
COMPONENT=weather

deploy () {
  
  az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $AKS_CLUSTER --admin
  echo "kube config merged"
  echo "Updating image for Deployment - $COMPONENT"
  DEPLOYMENT_APP=$(kubectl get deploy -n $NAME_SPACE | grep $COMPONENT | awk '{ print $1 }')
  if [[ $DEPLOYMENT_APP == $COMPONENT ]]
  then
      containerName=$(kubectl -n $NAME_SPACE get deployment $COMPONENT -o=jsonpath='{.spec.template.spec.containers[0].name}')
      kubectl -n $NAME_SPACE set image deployment $COMPONENT $containerName=$IMAGE_REPO:$IMAGE_TAG
  else

      echo "Deploying the weather application for the first time along with nginx deployment for api fetch"
      pushd $KUBE_DIR
      kubectl create -f k8s.yaml
      kubectl create -f nginx.yaml
      popd 
}

if [[ $GIT_BRANCH == 'master' ]]
then
  export RESOURCE_GROUP_NAME=$RESOURCE_GROUP_NAME_STAG
  export AKS_CLUSTER=$AKS_CLUSTER_STAG
  deploy
elif [[ $GIT_BRANCH == 'develop' ]]
then
  
  echo "Deployment in dev cluster ------ starting --------"
  export RESOURCE_GROUP_NAME=$RESOURCE_GROUP_NAME_DEV
  export AKS_CLUSTER=$AKS_CLUSTER_DEV
  deploy

else
  echo "//The origin branch should be develop or master"
fi