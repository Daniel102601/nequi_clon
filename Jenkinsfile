pipeline {
    agent any

    stages {
        stage('0. Limpieza de Seguridad') {
            steps {
                cleanWs()
                echo 'Borrando archivos viejos para asegurar que bajamos lo nuevo de GitHub...'
            }
        }

        stage('1. Obtener Código') {
            steps {
                echo 'Descargando la última versión desde GitHub...'
                checkout scm
            }
        }

        stage('2. Pruebas de Backend (API)') {
            steps {
                echo 'Ejecutando pruebas de Postman contra XAMPP...'
                // Newman funcionando con éxito
                bat 'C:\\Users\\Ramde\\AppData\\Roaming\\npm\\newman.cmd run test/api_tests.json'
            }
        }

        stage('3. Pruebas de Frontend (Flutter)') {
            steps {
                echo 'Ejecutando pruebas unitarias de Flutter...'
                // Usamos tu ruta exacta con doble barra invertida (\\)
                bat 'C:\\src\\flutter\\flutter\\flutter\\bin\\flutter.bat pub get'
                bat 'C:\\src\\flutter\\flutter\\flutter\\bin\\flutter.bat test'
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