pipeline {
    agent any
    environment {
        GIT_REPO = 'https://github.com/varmaaradhula/EKS-Jenkins.git'
        //GIT_BRANCH = 'stage' // Replace with your branch name
        TF_PATH = 'terraform' // Replace with your Terraform workspace, if applicable
        AWS_REGION = 'eu-west-2' // Replace with your AWS region
        S3_BUCKET = 'vprofilestate07' // Replace with your S3 bucket name
        S3_KEY = 'terraform/state/terraform.tfstate' // Replace with your desired state file path
        TERRAFORM_APPLY_SUCCESS = false
        GET_KUBE_CONFIG = false
    }
    stages {
        stage('Checkout Code') {
            steps {
                echo 'Checking out Terraform code from GitHub...'
                git branch: "${env.BRANCH_NAME}", url: "${GIT_REPO}"
            }
        }
        stage('Configure AWS Credentials') {
            steps {
                echo 'Configuring AWS credentials...'
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'awscreds' // Replace with your Jenkins AWS credentials ID
                ]]) {
                    sh '''
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                    aws configure set region ${AWS_REGION}
                    '''
                }
            }
        }
        stage('Terraform Init') {
            steps {
                echo 'Initializing Terraform with S3 backend...'
                dir("${TF_PATH}") {
                sh '''
                terraform init \
                    -backend-config="bucket=${S3_BUCKET}"
                '''
            }
        }
        }
        stage('Terraform Validate') {
            steps {
                echo 'Validating Terraform configuration...'
                dir("${TF_PATH}") {
                sh 'terraform validate'
            }
        }
        }
       // stage('Terraform Format') {
          // steps {
            //    echo 'Formatting Terraform configuration...'
             //   dir("${TF_PATH}") {
              //  sh 'terraform fmt -check -recursive'
           // }
       // }
       // }
        stage('Terraform Plan') {
           
            steps {
                echo 'Planning Terraform changes...'
                dir("${TF_PATH}") {
                sh 'terraform plan -out=tfplan'
            }
        }
        }
        stage('Terraform Apply') {
            when {
                expression { env.BRANCH_NAME == 'master' }
            }
            steps {
                echo 'Applying Terraform changes...'
                input message: 'Do you want to apply the changes?', ok: 'Apply'
                dir("${TF_PATH}") {
                sh 'terraform apply tfplan'
            }
            }
            post {
                success {
                    script {
                        echo 'Terraform Apply completed successfully.'
                        env.TERRAFORM_APPLY_SUCCESS = true
                    }
                }
                failure {
                    echo 'Terraform Apply failed.'
                }
            }
        }
        stage('Get Kubeconfig') {
            when {
                expression {
                    env.TERRAFORM_APPLY_SUCCESS == 'true'
                }
            }
            steps {
                echo 'Retrieving kubeconfig for EKS...'
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'aws-credentials-id' // Replace with your Jenkins AWS credentials ID
                ]]) {
                    sh '''
                    aws eks update-kubeconfig \
                        --region ${AWS_REGION} \
                        --name <your-eks-cluster-name> // Replace with your EKS cluster name
                    '''
                }
            }
             post {
                success {
                    script {
                        echo 'Terraform Apply completed successfully.'
                        env.GET_KUBE_CONFIG = true
                    }
                }
                failure {
                    echo 'Terraform Apply failed.'
                }
            }
        }
        stage('Install Ingress Controller') {
            when {
                expression {
                    env.GET_KUBE_CONFIG == 'true'
                }
            }
            steps {
                echo 'Installing ingress controller...'
                sh '''
                kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/aws/deploy.yaml
                '''
            }
        }
    }
    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
