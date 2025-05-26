pipelineJob("OCR") {
	description()
	keepDependencies(false)
	definition {
		cpsScm {
"""pipeline {
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

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                sh "docker build -t \${IMAGE_NAME} ."
            }
        }

        stage('Run Docker Container') {
            steps {
                echo '🚀 Running Docker container...'
                sh \"\"\"
                    docker rm -f \${CONTAINER_NAME} || true
                    docker run -d --name \${CONTAINER_NAME} -p 5000:5000 \${IMAGE_NAME}
                \"\"\"
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
}"""		}
	}
	disabled(false)
	configure {
		it / 'properties' / 'jenkins.model.BuildDiscarderProperty' {
			strategy {
				'daysToKeep'('-1')
				'numToKeep'('2')
				'artifactDaysToKeep'('-1')
				'artifactNumToKeep'('-1')
			}
		}
		it / 'properties' / 'com.coravy.hudson.plugins.github.GithubProjectProperty' {
			'projectUrl'('https://github.com/ayushriwas/project_main.git/')
			displayName()
		}
	}
}

listView("ocr") {
	jobs {
		name("OCR")
	}
	columns {
		status()
		weather()
		name()
		lastSuccess()
		lastFailure()
		lastDuration()
		buildButton()
	}
}
