pipeline {
  agent any

  tools {
    maven "M3"
    jdk "JDK21"
  }
  environment {
    REGION = "ap-northeast-2"
    DOCKERHUB_CREDENTIALS = credentials('DockerCredentials')
    AWS_CREDENTIALS_NAME = "AWSCredentilas"
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

    // Upload to S3
    stage('Upload to S3') {
       steps {
         echo 'Upload to S3'
         dir("${env.WORKSPACE}") {
             sh 'zip -r scripts.zip ./scripts appspec.yml'
             withAWS(region:"${REGION}", credentials:"${AWS_CREDENTIALS_NAME}") {
               s3Upload(file:"scripts.zip", bucket:"user01-codedeploy-bucket")
             }
             sh 'rm -rf ./scripts.zip'
        }
      }
    }
    // Code Deploy
    stage('CodeDeploy Deploy') {
            steps {
                withAWS(region: "${REGION}", credentials: 'AWSCredentials') {
                    sh '''
                    aws deploy create-deployment \
                    --application-name user00-code-deploy \
                    --deployment-config-name CodeDeployDefault.OneAtATime \
                    --deployment-group-name user01-code-deploy \
                    --s3-location bucket=user01-codedeploy-bucket,bundleType=zip,key=scripts.zip
                    '''
                }
                sleep(10)
            }
    }
  }
}
