pipeline{
	agent any
	stages {
		stage('checkout Github'){
			steps{
			git branch: 'main', credentialsId: 'Nodjs-project1-token', url: 'https://github.com/NayanJagtap/nodejs-project1.git'
			}
		}
		}
	}
