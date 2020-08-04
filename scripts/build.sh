#!/bin/bash -x
set -e
## Building the docker image ####
##Global Envs
  
echo $GIT_SOURCE
GIT_BRANCH=$(echo $GIT_SOURCE| awk -F "/" '{ print $3 }')
echo $GIT_BRANCH
echo $BUILD_ID


### Finding out, whether git tag or branch push ####


if [[ $GIT_BRANCH == 'master' ]]; then export IMAGE_TAG="$BUILD_ID-rc"
elif [[ $GIT_BRANCH == 'develop' ]]; then export IMAGE_TAG="$BUILD_ID-dev"
then
  export IMAGE_TAG=$BUILD_ID-$GIT_BRANCH
else 
  echo "Valid git branches for deployment- master, develop"
  exit 1
fi

if [ -z $IMAGE_TAG ]
then
  echo " no value for IMAGE TAG"
  exit 1
else 
  echo "image tag is .....  $IMAGE_TAG ....."


  ## Building Docker image##

  docker login -u "$DK_USER" -p "$DK_PASS"

  docker build -t "$IMAGE_REPO" .
  docker tag "$IMAGE_REPO" "$IMAGE_REPO:$IMAGE_TAG"
  echo "$IMAGE_REPO:$IMAGE_TAG"

  ## Logging into Docker Hub and push##
  
  docker push "$IMAGE_REPO:$IMAGE_TAG" && echo "The Latest image tag '$IMAGE_TAG' is pushed to DockerHub"
fi