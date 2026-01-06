pipeline {
    agent any
    tools {
        nodejs 'NodeJS'
    }
    environment {
        DOCKER_HUB_REPO = "nayandinkarjagtap/nodejs-project1"
        // ADD THIS: The ID of your credentials stored in Jenkins (Manage Jenkins > Credentials)
        DOCKER_HUB_CRED_ID = "nayandinkarjagtap" 
    }
    stages {
        stage('checkout Github') {
            steps {
                git branch: 'main', 
                    credentialsId: 'Nodjs-project1-token', 
                    url: 'https://github.com/NayanJagtap/nodejs-project1.git'
            }
        }
        stage('npm install') {
            steps {
                sh 'npm install'
            }
        }
        stage('docker image creation') {
            steps {
                script {
                    // We remove the 'def' to make it a global variable for this run
                    dockerImage = docker.build("${DOCKER_HUB_REPO}:latest")
                }
            }
        }
        stage('Trivy Scan') {
            steps {
                sh "trivy image --severity HIGH,CRITICAL --skip-update --no-progress --format table -o trivy-scan-report.txt ${DOCKER_HUB_REPO}:latest"
            }
        }
        stage('push the image to dockerhub') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', "${DOCKER_HUB_CRED_ID}") {
                        dockerImage.push('latest')
                    }
                }
            }
        }
    }
}
