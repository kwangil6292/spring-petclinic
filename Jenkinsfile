pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        DOCKER_IMAGE = 'kwangil1818/petclinic'
    }

    stages {
        stage('Git Clone') {
            steps {
                git url: 'https://github.com/kwangil6292/spring-petclinic.git', branch: 'main'
            }
        }

        stage('Install JDK 17') {
            steps {
                sh '''
                    export JAVA_HOME=/var/jenkins_home/jdk-17
                    if [ ! -d "$JAVA_HOME/bin" ]; then
                        curl -L -o /tmp/jdk17.tar.gz https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_x64_linux_hotspot_17.0.13_11.tar.gz
                        mkdir -p $JAVA_HOME
                        tar -xzf /tmp/jdk17.tar.gz -C $JAVA_HOME --strip-components=1
                        rm /tmp/jdk17.tar.gz
                    fi
                '''
            }
        }

        stage('Gradle Build') {
            steps {
                sh '''
                    export JAVA_HOME=/var/jenkins_home/jdk-17
                    export PATH=$JAVA_HOME/bin:$PATH
                    ./gradlew bootJar -x test --no-daemon \
                        -Dorg.gradle.java.home=$JAVA_HOME \
                        -Porg.gradle.java.installations.auto-detect=false \
                        -Porg.gradle.java.installations.auto-download=false
                '''
            }
            post {
                success { echo 'Gradle Build Success' }
                failure { echo 'Gradle Build Failed' }
            }
        }

        stage('Docker Image Build') {
            steps {
                sh """
                    docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                """
            }
        }

        stage('Docker Image Push') {
            steps {
                sh """
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE}:latest
                """
            }
        }

        stage('Docker Image Clean') {
            steps {
                sh "docker rmi -f ${DOCKER_IMAGE}:${BUILD_NUMBER}"
            }
        }

        stage('K8s Deploy') {
            steps {
                sh """
                    kubectl set image deployment/petclinic petclinic=${DOCKER_IMAGE}:${BUILD_NUMBER} -n user1-was
                    kubectl rollout status deployment/petclinic -n user1-was --timeout=60s
                """
            }
        }
    }
}
