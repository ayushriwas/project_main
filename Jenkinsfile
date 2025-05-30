pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'  // Change if needed
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📥 Checking out code...'
                git 'https://github.com/ayushriwas/project_main.git'
            }
        }

        stage('Prepare Lambda Package') {
            steps {
                dir('lambda') {
                    echo '📦 Building Lambda deployment package...'
                    sh '''
                        set -e
                        mkdir -p build/python
                        pip install -r requirements.txt -t build/python

                        cp lambda_function.py ocr_utils.py build/
                        cd build
                        zip -r ocr_lambda.zip .
                    '''
                }
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    echo '🌍 Running Terraform...'
                    sh '''
                        set -e
                        terraform init
                        terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                echo '🐳 Docker container should be running on EC2 if Terraform succeeded.'
            }
        }
    }

    post {
        failure {
            echo '❌ Build failed!'
        }
        success {
            echo '✅ Build and deploy successful!'
        }
    }
}
