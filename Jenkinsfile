pipeline {
  agent any

  tools {
    maven "M3"
    jdk "JDK17"
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
      }
    }
    // Docker Image 업로드
    stage('Docker Image Upload') {
      steps {
         echo 'Docker Image Upload'
      }
    }
    // Target로 *.jar 전송 
    stage('SSH Publish') {
      steps {
        echo 'SSH Publish'
      }
    }
    
  }
}
