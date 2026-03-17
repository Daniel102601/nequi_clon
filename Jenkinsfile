pipeline {
    agent any

    stages {
        stage('0. Configuración y Limpieza') {
            steps {
                cleanWs()
                echo 'Configurando permisos de Git y limpiando...'
                // Le decimos a Git que confíe en la carpeta de Flutter
                bat 'git config --global --add safe.directory C:/src/flutter/flutter/flutter'
            }
        }

        stage('1. Obtener Código') {
            steps {
                echo 'Descargando código...'
                checkout scm
            }
        }

        stage('2. Pruebas de Backend (API)') {
            steps {
                echo 'Ejecutando Newman...'
                bat 'C:\\Users\\Ramde\\AppData\\Roaming\\npm\\newman.cmd run test/api_tests.json'
            }
        }

        stage('3. Pruebas de Frontend (Flutter)') {
            steps {
                echo 'Ejecutando Flutter...'
                // Usamos tu ruta exacta
                bat 'C:\\src\\flutter\\flutter\\flutter\\bin\\flutter.bat pub get'
                bat 'C:\\src\\flutter\\flutter\\flutter\\bin\\flutter.bat test'
            }
        }
    }

    post {
        success {
            echo '✅ TODO EN VERDE: Eres un crack, Daniel.'
        }
        failure {
            echo '❌ FALLO: Revisa los permisos de la carpeta de Flutter.'
        }
    }
}