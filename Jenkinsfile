pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = 'e853f019-b741-4bea-8046-382a8f4764a7'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }
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
        stage('E2E & Deployment') {
            parallel {
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
                            node_modules/.bin/serve -s build & # Run the server in the background
                            sleep 10 # Wait for the server to start
                            npx playwright test --reporter=html --output=e2e-results
                        '''
                    }
                }
                stage('Deploy') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            echo "Deployment Stage"
                            npm install netlify-cli --save-dev
                            node_modules/.bin/netlify --version
                            node_modules/.bin/netlify status
                            node_modules/.bin/netlify deploy --dir=build --prod --skip-functions-build
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            junit testResults: '**/jest-results.xml', allowEmptyResults: true
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
        }
    }
}