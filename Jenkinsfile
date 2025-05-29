pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'ayush5626/ocr_web'
        CONTAINER_NAME = 'ocr'
        AWS_DEFAULT_REGION = 'us-east-1' // Set your AWS region
    }
    stages {
        stage('Cleanup') {
            steps {
                cleanWs()
            }
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

        stage('Run Docker Container') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    echo '🚀 Running Docker container...'
                    sh """
                        docker rm -f ${CONTAINER_NAME} || true
                        docker run -d --name ${CONTAINER_NAME} \
                          -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
                          -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
                          -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
                          -p 5000:5000 ${DOCKER_IMAGE}
                    """
                }
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

