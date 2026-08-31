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
                    test -f build/manifest.json || { echo "manifest.json not found!"; exit 1; }
                    test -f build/index.html || { echo "index.html not found!"; exit 1; }
                '''
            }
        }
    }
}