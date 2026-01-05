pipeline{
        agent any
        tools {
                nodejs 'NodeJS'
              }
        stages {
                stage('checkout Github'){
                        steps{
                        git branch: 'main', credentialsId: 'Nodjs-project1-token', url: 'https://github.com/NayanJagtap/nodejs-project1.git'
                        }
                }
                stage('npm install'){
                        steps{
                                sh 'npm install'
                             }
                                        }
                }
                }


