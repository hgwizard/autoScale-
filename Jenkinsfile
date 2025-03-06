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
                script {
                    try {
                        echo 'Running Snyk security scan...'
                        // Verify Snyk CLI is available
                        sh 'snyk --version || echo "Snyk CLI not found"'
                        
                        snykSecurity(
                            snykInstallation: 'newscan',
                            snykTokenId: 'snyk01',
                            additionalArguments: '--severity-threshold=low --iac', // Removed ${WORKSPACE} as it's implicit
                            failOnIssues: false,
                            monitorProjectOnBuild: false
                        )
                    } catch (Exception e) {
                        echo "Snyk scan failed with error: ${e.getMessage()}"
                        // Continue pipeline even if Snyk fails
                        currentBuild.result = 'UNSTABLE'
                    }
                }
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
        unstable {
            echo 'Pipeline completed but Snyk scan had issues'
        }
    }
}