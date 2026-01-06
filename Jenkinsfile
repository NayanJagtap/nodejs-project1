pipeline {
    agent any
    tools {
        nodejs 'NodeJS'
    }
    environment {
        // Fixed: Added the missing closing quote at the end of the URL
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
            // Fixed: Docker commands must be wrapped inside a 'steps' block
            steps {
                script {
                    docker.build("${DOCKER_HUB_REPO}:latest")
                }
            }
        }
	stage('Trivy Scan'){
	sh 'trivy --severity HIGH,CRITICAL --no-progress image --format table -o trivy-scan-report.txt ${DOCKER_HUB_REPO}:latest'
} 
    }
}
