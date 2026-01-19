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
    
  }
}
