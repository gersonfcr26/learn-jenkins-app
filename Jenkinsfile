pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = 'e853f019-b741-4bea-8046-382a8f4764a7'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.0.$BUILD_ID"
    }
    stages {
        /*
        stage('Docker') {
            steps {
                sh '''
                    echo "Docker Stage"
                    docker build -t my-playwright .
                '''
            }
        }
        */
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
        stage('Deploy') {
            parallel {
                stage('Deploy Staging') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            echo "Deployment Stage"
                            # pin to v17: v18+ needs Node 20.10+, image only has Node 18
                            npm install netlify-cli@17
                            npm install node-jq
                            node_modules/.bin/netlify --version
                            node_modules/.bin/netlify status
                            node_modules/.bin/netlify deploy --dir=build --json > netlify-deploy.json
                        '''
                        script {
                            env.STAGING_URL = sh(script: "node_modules/.bin/node-jq -r '.deploy_url' netlify-deploy.json", returnStdout: true).trim()
                        }
                    }
                }
                stage('Deploy Prod') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            echo "Deployment Prod"
                            # pin to v17: v18+ needs Node 20.10+, image only has Node 18
                            npm install netlify-cli@17
                            node_modules/.bin/netlify --version
                            node_modules/.bin/netlify status
                            node_modules/.bin/netlify deploy --dir=build --prod
                        '''
                    }
                }
            }
        }
        stage('E2E') {
            parallel {
                stage("Local E2E") {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                            //args '-u root:root' Not recomended to run as an admin user
                        }
                    }
                    steps {
                        sh '''
                            echo "Local E2E"
                            echo $CI_ENVIRONMENT_URL
                            npm  install serve
                            node_modules/.bin/serve -s build & # Run the server in the background
                            sleep 10 # Wait for the server to start
                            PLAYWRIGHT_HTML_REPORT=playwright-report-local npx playwright test --reporter=html --output=e2e-results-local
                        '''
                    }
                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report-local', reportFiles: 'index.html', reportName: 'Playwright HTML Report Local', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
                stage("Stage E2E") {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }
                    environment {
                        CI_ENVIRONMENT_URL = "${env.STAGING_URL}"
                    }
                    steps {
                        sh '''
                            echo "Stage E2E"
                            echo $CI_ENVIRONMENT_URL
                            #PLAYWRIGHT_HTML_REPORT=playwright-report-stage npx playwright test --reporter=html --output=e2e-results-stage
                        '''
                    }
                    /*
                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report-stage', reportFiles: 'index.html', reportName: 'Playwright HTML Report Staging', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                    */
                }
                stage("Prod E2E") {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }
                    environment {
                        CI_ENVIRONMENT_URL = 'https://sparkly-seahorse-5ec0a5.netlify.app'
                    }
                    steps {
                        sh '''
                            echo "Prod E2E"
                            echo $CI_ENVIRONMENT_URL
                            #PLAYWRIGHT_HTML_REPORT=playwright-report-prod npx playwright test --reporter=html --output=e2e-results-prod
                        '''
                    }
                    /*
                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report-prod', reportFiles: 'index.html', reportName: 'Playwright HTML Report Production', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                    */
                }
            }
        }
    }

    post {
        always {
            junit testResults: '**/jest-results.xml', allowEmptyResults: true
        }
    }
}