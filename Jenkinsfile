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
                sh 'rm -rf api-tests/build/test-results api-tests/build/allure-results build/junit build/allure-results'
                sh 'tools/build-test-base.sh'
            }
        }
        stage('Проверка конфигурации') {
            steps {
                sh 'xvfb-run -a tools/check-config.sh'
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
        stage('Обновление рабочей базы') {
            when {
                expression { env.GIT_BRANCH == 'origin/main' }
            }
            options {
                timeout(time: 1, unit: 'HOURS')
            }
            input {
                message 'Все тесты прошли. Обновить рабочую базу shelter-prod?'
                ok 'Обновить'
            }
            steps {
                script {
                    def rc = sh(script: 'tools/deploy-prod.sh', returnStatus: true)
                    if (rc == 102) {
                        def changes = readFile('build/restructure.txt').trim()
                        input message: "Обновление требует реструктуризации таблиц с данными:\n${changes}\n\nКопия prod уже сделана. Применить?",
                              ok: 'Применить'
                        sh 'FORCE_APPLY=1 tools/deploy-prod.sh'
                    } else if (rc != 0) {
                        error "deploy-prod.sh завершился с кодом ${rc}"
                    }
                }
            }
        }
    }

    post {
        always {
            junit allowEmptyResults: true,
                  testResults: 'api-tests/build/test-results/test/*.xml, build/junit/*.xml'
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

