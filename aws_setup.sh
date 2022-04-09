#!/bin/bash

set -x

install_docker=false
install_venv=false
login_ecr=false
build_docker_image=false
install_torchx=false

if [ "$install_venv" = true ]
then
    sudo apt-get install python3-venv
fi

# https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04
if [ "$install_docker" = true ]
then
    sudo apt-get update
    sudo apt-get remove docker docker-engine docker.io
    sudo apt install docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    docker --version
fi

if [ "$login_ecr" = true ]
then
    # Dev server: awsume api 495572122715 SSOAdmin
    # https://www.digitalocean.com/community/questions/how-to-fix-docker-got-permission-denied-while-trying-to-connect-to-the-docker-daemon-socket
    sudo chmod 666 /var/run/docker.sock
    aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $ECR_URL
fi 

python3 -m venv env
source env/bin/activate

if [ "$build_docker_image" = true ]
then
    docker build -f Dockerfile -t charnn:latest ./
    docker tag charnn:latest $ECR_URL/bwen:charnn
    docker push $ECR_URL/bwen:charnn
fi

if [ "$install_torchx" = true ]
then
    sudo apt install python3-pip
    pip3 install torch 
    pip3 install torchx

deactivate