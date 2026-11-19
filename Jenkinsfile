pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }

    stages {
        stage('Тесты API') {
            steps {
                sh 'tools/run-api-tests.sh'
            }
        }
    }
}
