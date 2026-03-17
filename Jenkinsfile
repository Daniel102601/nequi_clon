pipeline {
    agent any // Le dice a Jenkins que use cualquier recurso disponible

    stages {
        stage('1. Obtener Código') {
            steps {
                echo 'Descargando la última versión desde GitHub...'
                checkout scm
            }
        }

        stage('2. Pruebas de Backend (API)') {
            steps {
                echo 'Ejecutando pruebas de Postman contra XAMPP...'
                // Usa Newman para probar tu login.php
                bat 'newman run tests/api_tests.json'
            }
        }

        stage('3. Pruebas de Frontend (Flutter)') {
            steps {
                echo 'Ejecutando pruebas unitarias de Flutter...'
                // Descarga las dependencias y corre los tests
                bat 'flutter pub get'
                bat 'flutter test'
            }
        }
    }

    post {
        success {
            echo '✅ EXCELENTE INGENIERO: Todas las pruebas en verde. Código listo para producción.'
        }
        failure {
            echo '❌ ALERTA ROJA: Algo falló en las pruebas. Revisa los logs de la consola.'
        }
    }
}