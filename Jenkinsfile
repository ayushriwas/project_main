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
                echo '🐳 Building Docker image...'
                sh """
	            docker build -t ${IMAGE_NAME} .
		    docker push ${IMAGE_NAME}
		"""
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

