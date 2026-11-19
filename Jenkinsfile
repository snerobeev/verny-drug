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

    post {
        always {
            junit 'api-tests/build/test-results/test/*.xml'
            allure includeProperties: false,
                   results: [[path: 'api-tests/build/allure-results']]
        }
    }
} 

