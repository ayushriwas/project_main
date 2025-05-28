pipeline {
    agent any

    environment {
        IMAGE_NAME = 'ayush5626/ocr_web'
        CONTAINER_NAME = 'ocr'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📥 Checking out code...'
                git 'https://github.com/ayushriwas/project_main.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir('terraform') {
                        echo '🌍 Initializing Terraform...'
                        sh 'terraform init'

                        echo '🚀 Applying Terraform...'
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${DOCKER_IMAGE} .
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                sh "docker run -d -p 5000:5000 ${DOCKER_IMAGE}"
            }
        }
    }

    post {
        success {
            echo '✅ Deployment succeeded!'
        }
        failure {
            echo '❌ Build failed!'
        }
    }
}
