#! /bin/bash

echo "starting the installation"

sudo sysctl -w vm.max_map_count=524288

docker volume create sonarqube_data
docker volume create sonarqube_extensions
docker volume create sonarqube_logs
docker volume create postgresql
docker volume create postgresql_data
docker volume create jenkins_home

docker network create atnet

docker run -d --name postgresql \
--network atnet \
--restart always \
-e POSTGRES_USER=sonar \
-e POSTGRES_PASSWORD=sonaradmin \
-e POSTGRES_DB=sonarqubedb \
-v postgresql:/var/lib/postgresql \
-v postgresql_data:/var/lib/postgresql/data \
postgres:12.1-alpine

docker run -d --name sonarqube \
--network atnet -p 9000:9000 \
-e SONARQUBE_JDBC_URL=jdbc:postgresql://postgresql:5432/sonarqubedb \
-e SONARQUBE_JDBC_USERNAME=sonar \
-e SONARQUBE_JDBC_PASSWORD=sonaradmin \
-v sonarqube_data:/opt/sonarqube/data \
-v sonarqube_extensions:/opt/sonarqube/extensions \
-v sonarqube_logs:/opt/sonarqube/logs \
sonarqube:8.9.0-community

docker run -d --name jenkins \
--network atnet -p 8080:8080 -p 50000:50000 \
-v jenkins_home:/var/jenkins_home \
jenkins/jenkins:lts-jdk11

echo "Installation finished"

