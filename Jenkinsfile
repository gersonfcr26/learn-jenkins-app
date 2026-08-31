pipeline {
    agent any

    stages {
        stage('Test') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo "Test Stage"
                    node --version
                    npm --version
                    npm test
                '''
            }
        }
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -al
                    npm ci
                    npm run build
                    ls -al
                    test -f manifest.json || { echo "manifest.json not found!"; exit 1; }
                    test -f index.html || { echo "index.html not found!"; exit 1; }
                '''
            }
        }
    }
}