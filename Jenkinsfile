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

//         stage('Build Docker Image') {
//             steps {
//                 echo '🐳 Building Docker image...'
//                 sh """
//                     docker rm -f ${CONTAINER_NAME} || true
//                     docker rmi ${DOCKER_IMAGE} || true
//                     docker build -t ${DOCKER_IMAGE} .
//                 """
//             }
//         }

//         stage('Push Docker Image') {
//             steps {
//                 withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
//                     echo '📤 Pushing Docker image...'
//                     sh """
//                         echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
//                         docker push ${DOCKER_IMAGE}
//                     """
//                 }
//             }
//         }

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
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    echo '☁️ Uploading Lambda package to S3...'
                    sh '''
                        aws s3 cp lambda/build/ocr_lambda.zip s3://$S3_BUCKET/$S3_KEY --region $AWS_DEFAULT_REGION
                    '''
                }
            }
        }

        stage('Pre-check Existing Resources') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
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
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
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
                           terraform taint aws_lambda_permission.allow_s3_to_invoke || true

                           # Uncomment these if needed and if created before
                           # terraform taint aws_lambda_function.ocr_lambda || true
                           # terraform taint aws_iam_policy.terraform_lambda_admin_policy || true
                           # terraform taint aws_iam_user_policy_attachment.attach_lambda_admin_to_user || true

                            terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
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
