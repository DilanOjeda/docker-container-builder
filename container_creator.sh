#! /bin/bash

echo "starting the installation"

sudo sysctl -w vm.max_map_count=524288

docker volume create sonarqube_data
docker volume create sonarqube_extensions
docker volume create sonarqube_logs

docker network create atnet

mkdir ~/postgresql && mkdir ~/postgresl_data

docker run -d --name sonardb \
--network atnet -p 5432:5432 \
--restart always \
-e POSTGRES_USER=sonar \
-e POSTGRES_PASSWORD=sonaradmin \
-v postgresql:/var/lib/postgresql \
-v postgresql_data:/var/lib/postgresql/data \
postgres:12.1-alpine

docker run -d --name sonarqube \
--network atnet -p 9000:9000 \
-e SONARQUBE_JDBC_URL=jdbc:postgresql://sonardb:5432/sonar \
-e SONARQUBE_JDBC_USERNAME=sonar \
-e SONARQUBE_JDBC_PASSWORD=sonaradmin \
-v sonarqube_data:/opt/sonarqube/data \
-v sonarqube_extensions:/opt/sonarqube/extensions \
-v sonarqube_logs:/opt/sonarqube/logs \
sonarqube:8.9.0-community

docker run -d --name sonarjenkins \
--network atnet -p 8080:8080 -p 50000:50000 \
-v jenkins_home:/var/jenkins_home \
jenkins/jenkins:lts-jdk11

echo "Installation finished"

