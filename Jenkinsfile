pipeline {
  agent any
  environment {
    DOCKERHUB_CREDENTIALS = credentials('DockerCredentials')
    DOCKER_IMAGE = 'kwangil1818/petclinic'
  }
  stages {
    stage('Git Clone') {
      steps {
        git url: 'https://github.com/kwangil6292/spring-petclinic.git', branch: 'aws'
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
            -Dorg.gradle.java.home=$JAVA_HOME
        '''
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
          docker push ${DOCKER_IMAGE}:latest
        """
      }
    }
    stage('Docker Image Clean') {
      steps {
        sh "docker rmi -f ${DOCKER_IMAGE}:${BUILD_NUMBER}"
      }
    }
    stage('Upload to S3') {
      steps {
        dir("${env.WORKSPACE}") {
          sh 'zip -r scripts.zip ./scripts appspec.yml'
          sh 'aws s3 cp scripts.zip s3://user01-codedeploy-bucket/scripts.zip --region ap-northeast-2'
          sh 'rm -rf scripts.zip'
        }
      }
    }
    stage('배포 승인') {
      steps {
        input message: '운영 서버에 배포할까요?', ok: '배포 승인'
      }
    }
    stage('CodeDeploy') {
      steps {
        sh '''
          aws deploy create-deployment \
            --application-name user01-app \
            --deployment-config-name CodeDeployDefault.OneAtATime \
            --deployment-group-name user01-dg \
            --s3-location bucket=user01-codedeploy-bucket,bundleType=zip,key=scripts.zip \
            --region ap-northeast-2
        '''
      }
    }
  }
}
