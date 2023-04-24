pipeline {
  agent {
    docker {
      image 'alpine'
    }

  }
  stages {
    stage('ls') {
      steps {
        sh 'ls -la'
      }
    }

  }
}