pipeline{
    agent any
    environment{
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        AWS_DEFAULT_REGION    = 'ap-southeast-2'
        AWS_ACCOUNT_ID        = '500345929326'
        ECR_REPO              = "proj2_ecr"
        IMAGE_TAG             = "latest"
        ECR_URL               = "${AWS_ACCOUNT_ID}.dkr.ecr.ap-southeast-2.amazonaws.com"
        EC2_IP                = ''

    }
    stages{
        stage('Build Docker Image'){
            steps{
                echo "Builing Docker Image...."
                sh"docker build -t ${ ECR_REPO }:${ IMAGE_TAG } ."
            }
        }
        stage('push to ECR'){
            steps{
                echo "Pushing to ECR...."
                sh """
                 aws ecr get-login-password \
                 --region ${AWS_DEFAULT_REGION} | \
                 docker login \
                 --username AWS \
                 --password-stdin  ${ECR_URL}


                 docker tag ${ECR_REPO}:${IMAGE_TAG} \
                  ${ECR_URL}/${ECR_REPO}:${IMAGE_TAG}
                 
                 """
            }
        }
        stage('Terraform init'){
            steps{
                echo "Terraform init...."
                dir ('terraform'){
                     sh " terraform init"
                }
            }
        }
        stage('Terraform apply'){
            steps{
                echo "Terraform apply...."
                dir ('terraform'){
                sh "terraform apply -auto-approve"
                }
            }
        }
        stage('Update Kubeconfig'){
            steps{
                sh """
                aws eks update-kubeconfig \
                --region ${AWS_DEFAULT_REGION} \
                --name proj2_cluster
                """
            }
        }
        stage('Helm Deploy'){
            steps{
                sh """
                    helm upgrade --install todo-api ./helm/todo-api \
                        --set image.repository=${ECR_URL}/${ECR_REPO} \
                        --set image.tag=${IMAGE_TAG} \
                        --wait
                """
            }
        }

    }
    post {
        failure {
            sh 'helm rollback todo-api 0 || true'
        }
        success {
            echo "Pipeline completed! Image: ${ECR_URL}/${ECR_REPO}:${IMAGE_TAG}"
        }
    }

}
