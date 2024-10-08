pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'ravikishans'
        DOCKER_CREDENTIALS = credentials('ravikishans')

        BACKEND_NAMESPACE = 'backendrb'
        FRONTEND_NAMESPACE = 'frontendrb'
        DATABASE_NAMESPACE = 'databaserb'

        HELM_RELEASE_NAME = "resumebuilder"
        HELM_CHART_PATH = './k8s/resumebuilder'
    }

    stages {

        stage ('checkout code') {
            steps {
                script {
                    git branch: 'main' , url: 'https://github.com/Ravikishans/MEANproj.git'
                }
            }
        }
        stage("ls") {
            steps {
                script {
                    sh """
                    ls -al
                    """
                }
            }
        }

        stage ("add .env in backend") {
            steps {
                script {
                    sh """
                    echo 'JWT_SECRET_KEY="MYREALLYSECRETKEY"
                    MONGO_URL="mongodb+srv://ravikishan:Cluster0@cluster0.y9zohpu.mongodb.net/resumeai"
                    OPENAI_KEY="OPENAI_API_KEY"
                    GMAIL_USER="ravikishan1996@gmail.com"
                    GMAIL_PASS="123456789"
                    FRONT_END="http://localhost:80"' > ./ResumeBuilderBackend/.env

                    ls -al ./ResumeBuilderBackend
                    """
                }
            }
        }

        stage("add .env in frontend") {
            steps {
                script {
                    sh """
                    echo BACKEND_URL = "http://localhost:4292" > ./ResumeBuilderAngular/.env

                    ls -al ./ResumeBuilderAngular
                    """
                }
            }
        }
            

        stage('build and push docker images') {
            steps {
                script {
                    sh """
                        docker compose build
                        docker login -u ${DOCKER_CREDENTIALS_USR} -p ${DOCKER_CREDENTIALS_PSW}
                        docker compose push
                    """    
                }
            }
        }

        stage ('deploy to kubernates using helm') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'kubeconfig-credentials', variable: 'KUBECONFIG')])
                        sh """
                            helm upgrade --install ${HELM_RELEASE_NAME} ${HELM_CHART_PATH} --nsmespace default --create-namespace --kubeconfig=$KUBECONFIG --debug
                        """    
                }
            }
        }

        stage('verify deployment') {
            steps {
                script{
                    withCredentials([file(credentialsId: 'kubeconfig-credentials', variable: 'KUBECONFIG')])
                        sh "kubectl get pods -n ${BACKEND_NAMESPACE} --kubeconfig=$KUBECONFIG"
                        sh "kubectl get pods -n ${FRONTEND_NAMESPACE} --kubeconfig=$KUBECONFIG"
                        sh "kubectl get pods -n ${DATABASE_NAMESPACE} --kubeconfig=$KUBECONFIG"
                }
            }
        }
    }
    post {
        success {
            echo "Pipeline executed successfully!"
        }
        failure {
            echo "Pipeline failed"
        }
    }
}
