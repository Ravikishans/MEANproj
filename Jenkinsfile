pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'ravikishans'
        DOCKER_CREDENTIALS = credentials('ravikishans')

        BACKEND_NAMESPACE = 'backendRB'
        FRONTEND_NAMESPACE = 'frontendRB'
        DATABASE_NAMESPACE = 'databaseRB'

        HELM_RELEASE_NAME = "resumebuilder"
        HELM_CHART_PATH = '.k8s/helm-package/resumebuilder'
    }

    stages {

        stage ('checkout code') {
            steps {
                script {
                    git branch: 'main' , url: 'https://github.com/Ravikishans/MEANproj.git'
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
                    withCredentials([file(credentialsId: 'jubeconfig-credentials', variable: 'KUBECONFIG')])
                        sh """
                            helm upgrade --install ${HELM_RELEASE_NAME} ${HELM_CHART_PATH} \ --nsmespace default --create-namespace \ --kubeconfig=$KUBECONFIG --debug
                        """    
                }
            }
        }

        stage('verify deployment') {
            steps {
                script{
                    withCredentials([file(credentialsId: 'jubeconfig-credentials', variable: 'KUBECONFIG')])
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