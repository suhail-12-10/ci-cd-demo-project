pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds') // Create in Jenkins with your Docker Hub user/pass
        DOCKER_IMAGE = "suhail4545/demo-app"
        SERVER_IP = "16.16.198.243"
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
                withSonarQubeEnv('My SonarQube') { // Ensure this name matches your SonarQube config in Jenkins
                    sh 'cd backend && mvn sonar:sonar'
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
