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
                    npm ci
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

        stage("E2E") {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                    //args '-u root:root' Not recomended to run as an admin user
                }
            }
            steps {
                sh '''
                    echo "E2E Stage"
                    npm  install serve
                    node_modules/.bin/serve -s build & // Run the server in the background
                    sleep 10 // Wait for the server to start
                    npx playwright test
                '''
            }
        }
    }

    post {
        always {
            junit testResults: '**/test-results.xml', allowEmptyResults: true
        }
    }
}