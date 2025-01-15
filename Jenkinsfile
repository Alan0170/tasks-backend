pipeline {
    agent any

    stages {
        stage('Build Backend') {
            steps {
                bat 'mvn clean package -DskipTests=true'
            }
        }
        
        stage('Stage 2') {
            steps {
                echo 'End pipeline'
            }
        }
    }
}
