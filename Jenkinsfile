pipeline {
    agent any

    stages {
        stage('Hello') {
            agent {
                docker {
                    image 'alpine:latest'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -al
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -al
                '''
            }
        }
    }
}