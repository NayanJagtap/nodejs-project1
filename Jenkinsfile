pipeline {
    agent any
    tools {
        nodejs 'NodeJS'
    }
    environment {
        DOCKER_HUB_REPO = "nayandinkarjagtap/nodejs-project1"
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
                    docker.build("${DOCKER_HUB_REPO}:latest")
                }
            }
        }
        stage('Trivy Scan') {
            // Added: The required 'steps' block around the shell command
            steps {
                sh "trivy image --severity HIGH,CRITICAL --no-progress --format table -o trivy-scan-report.txt ${DOCKER_HUB_REPO}:latest"
            }
        }
    }
}
