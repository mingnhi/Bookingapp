pipeline {
    agent any

    environment {
        REGISTRY = "docker.io/${DOCKER_USERNAME}"
        IMAGE_NAME = "booking-backend"
        SERVER_HOST = "188.166.212.126"
        SERVER_USER = "root"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM',
                  branches: [[name: '*/main']],
                  userRemoteConfigs: [[
                    url: 'https://github.com/mingnhi/Bookingapp.git',
                    credentialsId: 'github-pat'
                  ]]
                ])
            }
        }

        stage('Build Backend Image') {
            steps {
                dir('backend') {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-cred',
                        usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                            echo "Building backend image..."
                            docker build -t docker.io/$DOCKER_USER/booking-backend:latest .
                        '''
                    }
                }
            }
        }

        stage('Build Frontend Image') {
            steps {
                dir('frontend') {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-cred',
                        usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                            echo "Building frontend image..."
                            docker build -t docker.io/$DOCKER_USER/booking-frontend:latest .
                        '''
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred',
                    usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push docker.io/$DOCKER_USER/booking-backend:latest
                        docker push docker.io/$DOCKER_USER/booking-frontend:latest
                    '''
                }
            }
        }
        stage('Deploy to Production Server') {
            steps {
                sshagent (credentials: ['server-ssh-key']) {
                    withCredentials([
                        usernamePassword(credentialsId: 'dockerhub-cred',
                            usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS'),
                        string(credentialsId: 'db-conn', variable: 'DB_CONN'),
                        file(credentialsId: 'docker-compose-file', variable: 'DOCKER_COMPOSE_PATH')
                    ]) {
                        sh '''
                            echo "Copying docker-compose file to server..."
                            scp -o StrictHostKeyChecking=no $DOCKER_COMPOSE_PATH $SERVER_USER@$SERVER_HOST:~/project/docker-compose.yml

                            echo "Deploying to production server..."
                            ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_HOST "
                                cd ~/project && \
                                echo \\"DB_CONNECTION_STRING=$DB_CONN\\" > .env && \
                                echo \\"MONGODB_URI=$DB_CONN\\" >> .env && \
                                echo \\"$DOCKER_PASS\\" | docker login -u $DOCKER_USER --password-stdin && \
                                docker compose --env-file .env pull && \
                                docker compose --env-file .env down && \
                                docker compose --env-file .env up -d && \
                                docker image prune -f
                            "
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo ' CI/CD pipeline completed successfully!'
        }
        failure {
            echo ' Build failed. Check logs for details.'
        }
    }
}
