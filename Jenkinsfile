pipeline {
    agent any

    tools {
        nodejs 'NodeJS'
    }

    environment {
        DOCKER_HUB_REPO = "nayandinkarjagtap/nodejs-project1"
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
                    def dockerImage = docker.build("${DOCKER_HUB_REPO}:latest")
                    docker.withRegistry('https://registry.hub.docker.com', "${DOCKER_HUB_CRED_ID}") {
                        dockerImage.push('latest')
                    }
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                sh "trivy image --severity HIGH,CRITICAL --skip-db-update --no-progress --format table -o trivy-scan-report.txt ${DOCKER_HUB_REPO}:latest"
            }
        }

        stage('install argocd cli and argo cli') {
            steps {
                sh '''
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

        stage('Apply kubernetes Manifests & sync app with argocd') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_PATH')]) {
                    script {
                        withEnv(["PATH+BIN=${WORKSPACE}/bin", "KUBECONFIG=${KUBECONFIG_PATH}"]) {
                            def pass = sh(script: "kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d", returnStdout: true).trim()
                            sh "argocd login 192.168.83.10:30844 --username admin --password ${pass} --insecure"
                            sh "argocd app sync nodejs-project"
                        }
                    }
                }
            }
        }
    }
}
