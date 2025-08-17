pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds') // Docker Hub credentials
        DOCKER_IMAGE = "suhail4545/demo-app"
        SERVER_IP = "16.16.195.79"
        SONARQUBE_TOKEN = credentials('sonar-token') // SonarQube token credential
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/suhail-12-10/ci-cd-demo-project.git'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'cd backend && mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('My SonarQube') { // Must match your Jenkins SonarQube config name
                    sh """
                    cd backend
                    mvn sonar:sonar \
                      -Dsonar.projectKey=demo-app \
                      -Dsonar.host.url=http://16.16.195.79:9000 \
                      -Dsonar.login=$SONARQUBE_TOKEN
                    """
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                sh """
                cd backend
                docker build -t $DOCKER_IMAGE:latest .
                echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                docker push $DOCKER_IMAGE:latest
                """
            }
        }

        stage('Deploy to Server') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) { // Create SSH key credential in Jenkins
                    sh """
                    ssh -o StrictHostKeyChecking=no ec2-user@$SERVER_IP "
                    docker pull $DOCKER_IMAGE:latest &&
                    docker stop demo-app || true &&
                    docker rm demo-app || true &&
                    docker run -d --name demo-app -p 9090:9090 $DOCKER_IMAGE:latest
                    "
                    """
                }
            }
        }
    }
}


