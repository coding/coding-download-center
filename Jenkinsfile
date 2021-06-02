pipeline {
  agent any
  stages {
    stage('检出') {
      steps {
        checkout([
          $class: 'GitSCM',
          branches: [[name: GIT_BUILD_REF]],
          userRemoteConfigs: [[
            url: GIT_REPO_URL,
            credentialsId: CREDENTIALS_ID
          ]]])
      }
    }
    stage('准备环境') {
      steps {
        sh 'npm install coding-generic -g'
      }
    }
    stage('下载和上传') {
      steps {
        withCredentials([
          usernamePassword(
            // CODING 持续集成的环境变量中内置了一个用于上传到当前项目制品库的凭证
            credentialsId: env.CODING_ARTIFACTS_CREDENTIALS_ID,
            usernameVariable: 'CODING_ARTIFACTS_USERNAME',
            passwordVariable: 'CODING_ARTIFACTS_PASSWORD'
          )]) {
          sh './coding-generic-sync.sh'
        }
      }
    }
  }
}