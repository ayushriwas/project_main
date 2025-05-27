pipeline {
    agent any

    environment {
        IMAGE_NAME = 'ayush5626/ocr_web'
        CONTAINER_NAME = 'ocr'
        TF_DIR = 'terraform' // assuming your Terraform config is in a `terraform/` subdirectory
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📥 Checking out code...'
                git 'https://github.com/ayushriwas/project_main.git'
            }
        }

        stage('Terraform Init') {
            steps {
                echo '🛠️ Initializing Terraform...'
                dir("${TF_DIR}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                echo '🔍 Validating Terraform configuration...'
                dir("${TF_DIR}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                echo '📋 Planning infrastructure changes...'
                dir("${TF_DIR}") {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                echo '🚀 Applying infrastructure...'
                dir("${TF_DIR}") {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Run Docker Container') {
            steps {
                echo '🚀 Running Docker container...'
                sh """
                    docker rm -f ${CONTAINER_NAME} || true
                    docker run -d --name ${CONTAINER_NAME} -p 5000:5000 ${IMAGE_NAME}
                """
            }
        }
    }

    post {
        always {
            echo '✅ Done.'
        }
        failure {
            echo '❌ Build failed!'
        }
    }
}
