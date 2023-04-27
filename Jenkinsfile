pipeline {
  agent {
    docker {
      image 'docker'
    }

  }
  stages {
    stage('ls') {
      steps {
        sh 'ls -laF'
      }
    }

  }
  environment {
    JENKINS_VERSION = '2.387.2'
  }
}