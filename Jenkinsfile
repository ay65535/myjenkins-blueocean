pipeline {
  agent {
    dockerfile {
      filename 'Dockerfile'
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