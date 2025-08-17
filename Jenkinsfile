pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds') // Docker Hub user/pass stored in Jenkins
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
                withSonarQubeEnv('My SonarQube') { // Name must match Jenkins SonarQube config
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh """
                        cd backend
                        mvn sonar:sonar \
                          -Dsonar.projectKey=demo \
                          -Dsonar.host.url=http://16.16.195.79:9000 \
                          -Dsonar.login=$SONAR_TOKEN
                        """
                    }
                }
            }
        }
         stage('SonarQube Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') { // waits up to 1 hour for analysis
                    waitForQualityGate abortPipeline: true
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
                sshagent (credentials: ['ec2-ssh-key']) { // Your EC2 SSH key stored in Jenkins
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

