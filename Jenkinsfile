pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-1' 
    }
    tools {
        jfrog 'jfrog-cli'
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

     stage ('Testing with JFrog') {
            steps {
                jf '-v' 
                jf 'c show'
                jf 'rt ping'
                sh 'touch test-file'
                jf 'rt u test-file jfrog-cli/'
                jf 'rt bp'
                jf 'rt dl jfrog-cli/test-file'
            }
        } 
    
        } 
    } 
     post {
        success {
            echo 'Pipeline execution completed successfully!'
        }
        failure {
            echo 'Pipeline execution failed!'
        }
    }

    


// pipeline{
//     agent any
//     tools {
//         jfrog 'jfrog-cli'
//     }
//     stages {
//         stage ('Testing') {
//             steps {
//                 jf '-v' 
//                 jf 'c show'
//                 jf 'rt ping'
//                 sh 'touch test-file'
//                 jf 'rt u test-file jfrog-cli/'
//                 jf 'rt bp'
//                 jf 'rt dl jfrog-cli/test-file'
//             }
//         } 
//     }
// }

// stage('Test') {
//     steps {
//         echo 'Pooping...'
//         snykSecurity(
//             snykInstallation: 'sneaky',  // Name of Snyk installation in Jenkins
//             snykTokenId: 'dober' , // Jenkins credential ID for Snyk API Token
//             additionalArguments: '--severity-threshold=low --iac ${WORKSPACE}',
//             failOnIssues: false ,
//             monitorProjectOnBuild: false  //
//         )
//     } 
// }