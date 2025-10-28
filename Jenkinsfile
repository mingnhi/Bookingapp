pipeline {
    agent any

    //  Thêm các tùy chọn để chống timeout + resume sau restart
    options {
        durabilityHint('MAX_SURVIVABILITY')  // Cho phép resume nếu Jenkins restart
        timeout(time: 90, unit: 'MINUTES')   // Cho phép build chạy tối đa 90 phút
        disableConcurrentBuilds()            // Ngăn 2 build song song (tránh đè file)
    }

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
                            echo "=== Starting frontend build ==="
                            free -h
                            docker system df
                            docker build --network=host --progress=plain \
                            -t docker.io/$DOCKER_USER/booking-frontend:latest .
                            echo "=== Build finished ==="
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
                        echo "Pushing images to Docker Hub..."
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
                    sh '''
                        echo "Creating project folder if missing..."
                        ssh -o StrictHostKeyChecking=no root@188.166.212.126 "mkdir -p ~/project"

                        echo "Copying docker-compose file to server..."
                        scp -o StrictHostKeyChecking=no $DOCKER_COMPOSE_PATH root@188.166.212.126:~/project/docker-compose.yml

                        echo "Deploying new version..."
                        ssh -o StrictHostKeyChecking=no root@188.166.212.126 "
                            cd ~/project && \
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

    post {
        success {
            echo 'CI/CD pipeline completed successfully!'
        }
        failure {
            echo ' Build failed. Check logs for details.'
        }
    }
}
