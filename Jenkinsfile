pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'ayush5626/ocr_web'
        CONTAINER_NAME = 'ocr'
        AWS_DEFAULT_REGION = 'us-east-1'
        S3_BUCKET = 'your-s3-bucket-name' // 🔁 Change this to your actual bucket
        S3_KEY = 'lambda/ocr_lambda.zip'
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

        stage('Upload to S3') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    echo '☁️ Uploading Lambda package to S3...'
                    sh '''
                        aws s3 cp lambda/build/ocr_lambda.zip s3://$S3_BUCKET/$S3_KEY --region $AWS_DEFAULT_REGION
                    '''
                }
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    dir('terraform') {
                        echo '🌍 Running Terraform...'
                        sh '''
                            export TF_VAR_lambda_s3_bucket=$S3_BUCKET
                            export TF_VAR_lambda_s3_key=$S3_KEY
                            terraform init
                            terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    echo '🚀 Running Docker container...'
                    sh '''
                        docker rm -f ${CONTAINER_NAME} || true
                        docker run -d --name ${CONTAINER_NAME} \
                          -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
                          -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
                          -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
                          -p 5000:5000 ${DOCKER_IMAGE}
                    '''
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
