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

        stage('Checkout') {
            steps {
                echo '📥 Checking out code...'
                git 'https://github.com/ayushriwas/project_main.git'
            }
        }

        stage('Terraform Init & Import') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir('terraform') {
                        echo '🌍 Initializing Terraform...'
                        sh 'terraform init'

                        echo '📦 Importing existing S3 bucket if not already managed...'
                        sh '''
                            if ! terraform state list | grep -q aws_s3_bucket.ocr_bucket; then
                              terraform import aws_s3_bucket.ocr_bucket ocr-images-bucket-e6a2ac1e
                            else
                              echo "✅ Bucket already imported in state."
                            fi
                        '''
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir('terraform') {
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
