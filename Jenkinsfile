pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        AWS_DEFAULT_REGION    = 'ap-southeast-2'
        AWS_ACCOUNT_ID        = '500345929326'
        ECR_REPO              = "proj2_ecr"
        IMAGE_TAG             = "${env.BUILD_NUMBER}"
        ECR_URL               = "${AWS_ACCOUNT_ID}.dkr.ecr.ap-southeast-2.amazonaws.com"
    }

    stages {

        stage('Clean Workspace') {
            steps {
                sh "rm -rf ${WORKSPACE}/terraform/.terraform ${WORKSPACE}/terraform/.terraform.lock.hcl"
            }
        }

        stage('Git Checkout') {
            steps {
                git url: "https://github.com/Gaurimandlik10/Node.js-REST-API.git",
                    branch: "main"
            }
        }


        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh "terraform init -reconfigure"
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh "terraform apply -auto-approve"
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${ECR_REPO}:${IMAGE_TAG} ./app"
            }
        }

        stage('Push to ECR') {
            steps {
                sh """
                    aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_URL}
                    docker tag ${ECR_REPO}:${IMAGE_TAG} ${ECR_URL}/${ECR_REPO}:${IMAGE_TAG}
                    docker push ${ECR_URL}/${ECR_REPO}:${IMAGE_TAG}
                """
            }
        }

        stage('Update Kubeconfig') {
            steps {
                sh "aws eks update-kubeconfig --region ${AWS_DEFAULT_REGION} --name proj2_cluster"
            }
        }

        stage('Helm Deploy') {
            steps {
                sh "helm upgrade --install todo-api ./helm/todo-api --set image.repository=${ECR_URL}/${ECR_REPO} --set image.tag=${IMAGE_TAG} --wait"
            }
        }
    }

    post {
        failure {
            echo "Pipeline failed at build ${IMAGE_TAG}"
        }
        success {
            echo "Pipeline completed! Image: ${ECR_URL}/${ECR_REPO}:${IMAGE_TAG}"
        }
    }
}
