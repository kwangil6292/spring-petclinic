pipeline {
  agent any

  tools {
    maven "M3"
    jdk "JDK17"
  }
  
  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerCredential')
  }
  
  stages {
    stage('Git Clone') {
      steps  {
        git url: 'https://github.com/kwangil6292/spring-petclinic.git/', branch: 'main'
      }
    }
    stage('Maven Build') {
      steps {
        sh 'mvn -Dmaven.test.failure.ignore=true clean package'
      }
      post {
        success {
          echo 'Maven Build Success'
        } 
        failure {
          echo 'Maven Buuld Failed'
        }
      }
    }
    // Docker Image 생성
    stage('Docker Image Build') {
      steps {
        echo 'Docker Image Build'
        dir("${env.WORKSPACE}") {
          sh """
          docker build -t spring-petclinic:$BUILD_NUMBER .
          docker tag spring-petclinic:$BUILD_NUMBER kwangil1818/spring-petclinic:latest
          """
        }
      }
    }
    // Docker Image 업로드
    stage('Docker Image Upload') {
      steps {
         echo 'Docker Image Upload'
         sh """
         echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
         docker push kwangil1818/spring-petclinic:latest
         """
      }
    }

    // Docker Image Remove
    stage('Docker Image Remove') {
      steps {
        echo 'Docker Image Remove'
        sh 'docker rmi -f spring-petclinic:$BUILD_NUMBER'
      }
    }

    // SSH Publish
    stage('SSH Publish') {
      steps {
        echo 'SSH Publish'
        shPublisher(publishers: [sshPublisherDesc(configName: 'target', 
        transfers: [sshTransfer(cleanRemote: false, 
        excludes: '',
        execCommand: 
        '''docker rm -f $(docker ps -aq)
        docker rmi -f $(docker images -q)
        docker run -itd -p 80:8080 --name=spring-petclinic kwangil1818/spring-petclinic:latest
        ''',
        execTimeout: 120000, 
        flatten: false, 
        makeEmptyDirs: false, 
        noDefaultExcludes: false, 
        patternSeparator: '[, ]+', 
        remoteDirectory: '', 
        remoteDirectorySDF: false, 
        removePrefix: 'target', sourceFiles: '')], 
        usePromotionTimestamp: false, 
        useWorkspaceInPromotion: false, verbose: false)])
      }
    }    
  }
}
