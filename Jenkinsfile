pipeline {
    agent any

    stages {
        // PASO CLAVE: Borramos lo viejo antes de empezar
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
                // Usamos la ruta absoluta que ya sabemos que funciona en tu PC
                bat 'C:\\Users\\Ramde\\AppData\\Roaming\\npm\\newman.cmd run test/api_tests.json'
            }
        }

        stage('3. Pruebas de Frontend (Flutter)') {
            steps {
                echo 'Ejecutando pruebas unitarias de Flutter...'
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