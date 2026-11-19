pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }

    triggers {
        pollSCM('H/5 * * * *')
    }

    stages {
        stage('Сборка тестовой базы') {
            steps {
                sh 'tools/build-test-base.sh'
            }
        }
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
