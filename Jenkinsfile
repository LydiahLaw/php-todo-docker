pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = "lydiahlaw"
        IMAGE_NAME = "php-todo"
        IMAGE_TAG = "${env.BRANCH_NAME.replace('/', '-')}-0.0.1"
        TEST_CONTAINER = "test-todo-${env.BRANCH_NAME.replace('/', '-')}"
    }

    stages {

        stage('Initial Cleanup') {
            steps {
                dir("${WORKSPACE}") {
                    deleteDir()
                }
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage('Test') {
            steps {
                sh """
                    docker rm -f ${TEST_CONTAINER} || true
                    docker run --name ${TEST_CONTAINER} \
                        --network tooling_app_network \
                        -e DB_HOST=mysqlserverhost \
                        -e DB_DATABASE=tododb \
                        -e DB_USERNAME=webaccess \
                        -e DB_PASSWORD=Devopslearn# \
                        -d ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
                    sleep 15
                    STATUS=\$(docker run --rm --network tooling_app_network curlimages/curl:latest \
                        curl -s -o /dev/null -w "%{http_code}" http://${TEST_CONTAINER}:80)
                    echo "HTTP Status: \$STATUS"
                    echo "\$STATUS" | grep -E "200|302"
                """
            }
            post {
                always {
                    sh "docker rm -f ${TEST_CONTAINER} || true"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ''' + "${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}" + '''
                    '''
                }
            }
        }

        stage('Cleanup Images') {
            steps {
                sh """
                    docker rmi ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} || true
                """
            }
        }
    }

    post {
        always {
            sh 'docker logout'
        }
    }
}
