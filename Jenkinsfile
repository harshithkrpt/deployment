pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        AWS_ACCOUNT_ID = "YOUR_ACCOUNT_ID"

        BACKEND_REPO = "todo-api"
        UI_REPO      = "todo-ui"

        IMAGE_TAG = "${env.GIT_COMMIT}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Login to ECR') {
            steps {
                sh """
                aws ecr get-login-password --region $AWS_REGION \
                | docker login \
                  --username AWS \
                  --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                """
            }
        }

        stage('Build Backend Image') {
            steps {
                dir("backend") {
                    sh """
                    docker build -t $BACKEND_REPO:$IMAGE_TAG .
                    docker tag $BACKEND_REPO:$IMAGE_TAG \
                    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO:$IMAGE_TAG
                    """
                }
            }
        }

        stage('Build UI Image') {
            steps {
                dir("ui") {
                    sh """
                    docker build -t $UI_REPO:$IMAGE_TAG .
                    docker tag $UI_REPO:$IMAGE_TAG \
                    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$UI_REPO:$IMAGE_TAG
                    """
                }
            }
        }

        stage('Push Images') {
            steps {
                sh """
                docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO:$IMAGE_TAG
                docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$UI_REPO:$IMAGE_TAG
                """
            }
        }

        stage('Output Image URIs') {
            steps {
                sh """
                echo "API_IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO:$IMAGE_TAG"
                echo "UI_IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$UI_REPO:$IMAGE_TAG"
                """
            }
        }
    }

    post {
        always {
            sh "docker system prune -f"
        }
    }
}