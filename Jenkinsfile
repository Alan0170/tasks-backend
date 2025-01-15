pipeline {
    agent any

    stages {
        stage('Build Backend') {
            steps {
                bat 'mvn clean package -DskipTests=true'
            }
        }
        
        stage('Unit tests') {
            steps {
                bat 'mvn test'
            }
        }
    }
}
