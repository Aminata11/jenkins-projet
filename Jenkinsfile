pipeline {
    agent any
    

    environment {
        DOCKER_HUB_REPO = 'aminata286'
        SONAR_TOKEN = credentials('mon-token-sonar')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(
                    branches: [[name: '*/main']],
                    extensions: [],
                    userRemoteConfigs: [[
                        credentialsId: 'token-git',
                        url: 'https://github.com/Aminata11/jenkins-projet.git'
                    ]]
                )
            }
        }

    stage('SonarQube Analysis') {
            steps {
               withSonarQubeEnv('sonar-server') {
                sh '/opt/sonar-scanner/bin/sonar-scanner'
               }

            }
        }

    stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Backend Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_HUB_REPO}/backend:latest ./mon-projet-express"
                }
            }
        }
      
        stage('Build Frontend Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_HUB_REPO}/frontend:latest ./"
                }
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'token-docker',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        stage('Push Images') {
            steps {
                script {
                    sh "docker push ${DOCKER_HUB_REPO}/backend:latest"
                    sh "docker push ${DOCKER_HUB_REPO}/frontend:latest"
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                script {
                    sh 'docker compose down || true'
                    sh 'docker compose up -d'
                }
            }
        }
    }

    post {
        success {
            emailext(
                subject: "✅ BUILD REUSSI - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """<html>
                    <body>
                        <p>Bonjour,</p>
                        <p>Le job <b>${env.JOB_NAME}</b> (build #${env.BUILD_NUMBER}) a été exécuté avec succès.</p>
                        <p>Consultez les logs ici : <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                    </body>
                </html>""",
                to: 'seckaminata87@gmail.com',
                from: 'seckaminata87@gmail.com',
                replyTo: 'seckaminata87@gmail.com',
                mimeType: 'text/html'
            )
        }

        failure {
            emailext(
                subject: "❌ BUILD ECHOUE - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """<html>
                    <body>
                        <p>Bonjour,</p>
                        <p>Le job <b>${env.JOB_NAME}</b> (build #${env.BUILD_NUMBER}) a échoué.</p>
                        <p>Consultez les logs ici : <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                    </body>
                </html>""",
                to: 'seckaminata87@gmail.com',
                from: 'seckaminata87@gmail.com',
                replyTo: 'seckaminata87@gmail.com',
                mimeType: 'text/html'
            )
        }

        always {
            sh 'docker logout'
        }
    }
}
