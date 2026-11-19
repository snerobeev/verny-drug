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
        stage('Сценарии Vanessa') {
            steps {
                sh 'xvfb-run -a tools/run-tests.sh'
            }
        }
    }

    post {
        always {
            junit 'api-tests/build/test-results/test/*.xml, build/junit/*.xml'
            sh '''
                rm -rf allure-results
                mkdir -p allure-results
                cp -r api-tests/build/allure-results/. allure-results/ 2>/dev/null || true
                cp -r build/allure-results/. allure-results/ 2>/dev/null || true
                rm -rf allure-results/history
            '''
            allure includeProperties: false,
                   results: [[path: 'allure-results']]
        }
    }
}

