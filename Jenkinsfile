pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-1'
    }
    stages {
        stage('Set AWS Credentials') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Access_key2'
                ]]) {
                    sh '''
                    echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
                    aws sts get-caller-identity
                    '''
                }
            }
        }
        
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/hgwizard/autoScale-.git'
            }
        }
        
        stage('Initialize Terraform') {
            steps {
                sh '''
                terraform init
                '''
            }
        }
        
        stage('Snyk Security Scan') {
            steps {
                echo 'Running Snyk security scan...'
                snykSecurity(
                    snykInstallation: 'newscan',          // Name of Snyk installation in Jenkins
                    snykTokenId: 'snyk01',              // Jenkins credential ID for Snyk API Token
                    additionalArguments: '--severity-threshold=low --iac ${WORKSPACE}',
                    failOnIssues: false,               // Won't fail the build on vulnerabilities
                    monitorProjectOnBuild: false       // Won't monitor project in Snyk dashboard
                )
            }
        }
        
        stage('Plan Terraform') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Access_key2'
                ]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    terraform plan -out=tfplan
                    '''
                }
            }
        }
        
        stage('Apply Terraform') {
            steps {
                input message: "Approve Terraform Apply?", ok: "Deploy"
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Access_key2'
                ]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    terraform apply -auto-approve tfplan
                    '''
                }
            }
        }
    }
    post {
        success {
            echo 'Terraform deployment and Snyk scan completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}