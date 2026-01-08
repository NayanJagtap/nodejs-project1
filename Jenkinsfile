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
                    echo 'building docker image...'
                    def dockerImage = docker.build("${DOCKER_HUB_REPO}:latest")
                }
            }
        }
        stage('Trivy Scan'){
            steps {
                sh "trivy image --severity HIGH,CRITICAL --skip-db-update --no-progress --format table -o trivy-scan-report.txt ${DOCKER_HUB_REPO}:latest"
            }
        }
        stage('Push Image to DockerHub'){
            steps {
                script {
                    echo 'pushing docker image to DockerHub...'
                    docker.withRegistry('https://registry.hub.docker.com', "${DOCKER_HUB_CREDENTIALS_ID}"){
                        dockerImage.push('latest')
                    }
                }
            }
        }
        stage('Install Kubectl & ArgoCD CLI'){
            steps {
                sh '''
                echo 'installing Kubectl & ArgoCD cli...'
                mkdir -p ./bin
                curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                chmod +x kubectl
                mv kubectl ./bin/
                curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
                chmod +x argocd
                mv argocd ./bin/
                '''
            }
        }
        stage('Apply Kubernetes Manifests & Sync App with ArgoCD'){
            steps {
                // Using 'file' type to handle the Secret File upload correctly
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_PATH')]) {
                    script {
                        // Forcing the local bin to be the first place Jenkins looks for tools
                        withEnv(["PATH=${WORKSPACE}/bin:${env.PATH}", "KUBECONFIG=${KUBECONFIG_PATH}"]) {
                            
                            // 1. Test the kubeconfig formatting immediately
                            sh 'kubectl version --client'
                            
                            // 2. Fetch ArgoCD Password
                            def pass = sh(script: "kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d", returnStdout: true).trim()
                            
                            // 3. Login and Sync
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
        success {
            echo 'Build & Deploy completed successfully!'
        }
        failure {
            echo 'Build & Deploy failed. Check logs.'
        }
    }
}
