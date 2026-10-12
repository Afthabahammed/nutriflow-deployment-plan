pipeline {
    agent any

    options {
        timestamps()
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    tools {
        nodejs 'NodeJS-22'
    }

    environment {
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '268666184272'
        FRONTEND_REPO = 'nutriflow-frontend'
        BACKEND_REPO = 'nutriflow-backend'
        SONAR_PROJECT_KEY = 'nutriflow'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh '''
                    echo "Branch: ${BRANCH_NAME:-main}"
                    git log -1 --oneline
                    test -f frontend/package.json
                    test -f backend/package.json
                    test -f frontend/Dockerfile
                    test -f backend/Dockerfile
                '''
            }
        }

        stage('Frontend Checks') {
            steps {
                dir('frontend') {
                    sh '''
                        npm ci
                        npm run build
                    '''
                }
            }
        }

        
stage('Backend Checks') {
    steps {
        dir('backend') {
            sh '''
                npm ci
                node --check index.js
            '''
        }
    }
}


        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarQubeScanner'

                    withSonarQubeEnv('sonarqube') {
                        sh """
                            "\${scannerHome}/bin/sonar-scanner" \
                              -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                              -Dsonar.projectName=NutriFlow \
                              -Dsonar.sources=frontend/src,backend \
                              -Dsonar.exclusions=**/node_modules/**,**/dist/**,**/coverage/**,**/package-lock.json
                        """
                    }
                }
            }
        }

        stage('Build and Push Images') {
            steps {
                sh '''
                    set -eu

                    REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
                    TAG="${BUILD_NUMBER}"

                    aws ecr get-login-password --region "${AWS_REGION}" \
                      | docker login --username AWS --password-stdin "${REGISTRY}"

                    docker build \
                      -t "${REGISTRY}/${FRONTEND_REPO}:${TAG}" \
                      -t "${REGISTRY}/${FRONTEND_REPO}:latest" \
                      ./frontend

                    docker build \
                      -t "${REGISTRY}/${BACKEND_REPO}:${TAG}" \
                      -t "${REGISTRY}/${BACKEND_REPO}:latest" \
                      ./backend

                    docker push "${REGISTRY}/${FRONTEND_REPO}:${TAG}"
                    docker push "${REGISTRY}/${FRONTEND_REPO}:latest"
                    docker push "${REGISTRY}/${BACKEND_REPO}:${TAG}"
                    docker push "${REGISTRY}/${BACKEND_REPO}:latest"

                    docker logout "${REGISTRY}"
                '''
            }
        }
    }

    post {
        always {
            sh '''
                docker image prune -f || true
            '''
            cleanWs()
        }
        success {
            echo 'NutriFlow CI completed successfully. Images have been pushed to ECR.'
        }
        failure {
            echo 'NutriFlow CI failed. Review the failed stage in the Jenkins console output.'
        }
    }
}
