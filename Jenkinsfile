pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'ayush5626/ocr_web'
        CONTAINER_NAME = 'ocr'
        AWS_DEFAULT_REGION = 'us-east-1'
        S3_BUCKET = 'ocr-images-bucket-e6a2ac1e' // 🔁 Change this to your actual bucket
        S3_KEY = 'lambda/ocr_lambda.zip'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📥 Checking out code...'
                git 'https://github.com/ayushriwas/project_main.git'
            }
        }

        // Build and Push Docker image stages (optional) are commented out.

        stage('Prepare Lambda Package with OpenCV') {
            steps {
                dir('lambda') {
                    echo '📦 Building Lambda package with OpenCV using Docker...'
                    sh '''
                        mkdir -p build
                        docker build -t lambda-builder .
			docker run --rm -v "$PWD/build":/output lambda-builder \
                        cp /opt/lambda/ocr_lambda.zip /output/ocr_lambda.zip
                    '''
                }
            }
        }

        stage('Ensure S3 Bucket Exists') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    echo '🪣 Ensuring S3 bucket exists...'
                    sh '''
                        if aws s3api head-bucket --bucket "$S3_BUCKET" 2>/dev/null; then
                            echo "✅ Bucket already exists."
                        else
                            echo "🪣 Creating bucket..."
                            if [ "$AWS_DEFAULT_REGION" = "us-east-1" ]; then
                                aws s3api create-bucket --bucket "$S3_BUCKET" --region "$AWS_DEFAULT_REGION"
                            else
                                aws s3api create-bucket --bucket "$S3_BUCKET" \
                                    --region "$AWS_DEFAULT_REGION" \
                                    --create-bucket-configuration LocationConstraint="$AWS_DEFAULT_REGION"
                            fi
                            aws s3api wait bucket-exists --bucket "$S3_BUCKET" --region "$AWS_DEFAULT_REGION"
                        fi
                    '''
                }
            }
        }

        stage('Upload to S3') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    echo '☁️ Uploading Lambda package to S3 (only if not already present)...'
                    sh '''
                        if aws s3api head-object --bucket "$S3_BUCKET" --key "$S3_KEY" 2>/dev/null; then
                            echo "⚠️ Lambda package already exists at s3://$S3_BUCKET/$S3_KEY. Skipping upload."
                        else
                            echo "📤 Uploading Lambda package to S3..."
                            aws s3 cp lambda/build/ocr_lambda.zip s3://$S3_BUCKET/$S3_KEY --region $AWS_DEFAULT_REGION
                        fi
                    '''
                }
            }
        }

        stage('Pre-check Existing Resources') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    echo '🔍 Checking if Lambda function already exists...'
                    sh '''
                        if aws lambda get-function --function-name ocr_lambda --region $AWS_DEFAULT_REGION > /dev/null 2>&1; then
                            echo "✅ Lambda function already exists. Skipping creation in Terraform."
                            echo 'TF_VAR_lambda_exists=true' > terraform/precheck_env.sh
                        else
                            echo "⚠️ Lambda function does NOT exist. It will be created."
                            echo 'TF_VAR_lambda_exists=false' > terraform/precheck_env.sh
                        fi
                    '''
                }
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    dir('terraform') {
                        echo '🌍 Running Terraform...'
                        sh '''
                            source precheck_env.sh || true

                            export TF_VAR_lambda_s3_bucket=$S3_BUCKET
                            export TF_VAR_lambda_s3_key=$S3_KEY
                            export TF_VAR_lambda_exists=${TF_VAR_lambda_exists:-false}

                            terraform init

                            # Taint existing IAM-related resources
                            terraform taint aws_iam_role.ocr_ec2_role || true
                            terraform taint aws_iam_policy.ocr_s3_policy || true
                            terraform taint aws_iam_role_policy_attachment.attach_s3_policy_to_ec2 || true
                            terraform taint aws_iam_instance_profile.ocr_instance_profile || true

                            terraform taint aws_iam_role.ocr_lambda_exec || true
                            terraform taint aws_iam_policy.ocr_lambda_policy || true
                            terraform taint aws_iam_role_policy_attachment.attach_lambda_policy || true

                            # Optional (only if created)
                            # terraform taint aws_lambda_permission.allow_s3_to_invoke || true

                            # Uncomment these if needed and if created before
                            # terraform taint aws_lambda_function.ocr_lambda || true
                            terraform taint aws_iam_policy.terraform_lambda_admin_policy || true
                            terraform taint aws_iam_user_policy_attachment.attach_lambda_admin_to_user || true

                            terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    echo '🚀 Running Docker container...'
                    sh '''
                        docker rm -f ${CONTAINER_NAME} || true
                        #docker rmi ${DOCKER_IMAGE}
                        #docker pull ${DOCKER_IMAGE}
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
