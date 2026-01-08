pipeline {
    agent any
    tools {
        nodejs 'NodeJS'
    }
    environment {
        DOCKER_HUB_REPO = 'nayandinkarjagtap/nodejs-project1'
        DOCKER_HUB_CREDENTIALS_ID = 'nayandinkarjagtap'
    }
    stages {
        stage('Checkout Github'){
            steps {
                git branch: 'main', credentialsId: 'Nodjs-project1-token', url: 'https://github.com/NayanJagtap/nodejs-project1.git'
            }
        }       
        stage('Install node dependencies'){
            steps {
                sh 'npm install'
            }
        }
        stage('Build Docker Image'){
            steps {
                script {
                    def dockerImage = docker.build("${DOCKER_HUB_REPO}:latest")
                    docker.withRegistry('https://registry.hub.docker.com', "${DOCKER_HUB_CREDENTIALS_ID}"){
                        dockerImage.push('latest')
                    }
                }
            }
        }
        stage('Trivy Scan'){
            steps {
                sh "trivy image --severity HIGH,CRITICAL --skip-db-update --no-progress --format table -o trivy-scan-report.txt ${DOCKER_HUB_REPO}:latest"
            }
        }
        stage('Install ArgoCD CLI'){
            steps {
                // We only need to download ArgoCD CLI since kubectl is now on your host
                sh '''
                mkdir -p ./bin
                curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
                chmod +x argocd
                mv argocd ./bin/
                '''
            }
        }
        stage('Apply Kubernetes Manifests & Sync App with ArgoCD'){
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_PATH')]) {
                    script {
                        // PATH includes ./bin for argocd and system path for kubectl
                        withEnv(["PATH=${WORKSPACE}/bin:${env.PATH}", "KUBECONFIG=${KUBECONFIG_PATH}"]) {
                            
                            // 1. Verify kubectl can read your new clean config
                            sh 'kubectl version --client'
                            
                            // 2. Fetch ArgoCD Password
                            def pass = sh(script: "kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d", returnStdout: true).trim()
                            
                            // 3. Login to ArgoCD (Internal Minikube IP) and Sync
                            sh """
                            argocd login 192.168.49.2:30844 --username admin --password ${pass} --insecure
                            argocd app sync nodejs-project
                            """
                        }
                    }   
                }
            }
        }
    }
    post {
        success { echo 'Build & Deploy completed successfully!' }
        failure { echo 'Build & Deploy failed. Check logs.' }
    }
}
