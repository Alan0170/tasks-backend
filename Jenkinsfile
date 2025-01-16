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

        stage('Sonar Analysis') {
            environment {
                scannerHome = tool 'SONAR_SCANNER'
            }
            steps {
                withSonarQubeEnv('SONAR_LOCAL') {
                bat """${scannerHome}/bin/sonar-scanner -e -Dsonar.projectKey=DeployBackend \
                -Dsonar.host.url=http://localhost:9000 \
                -Dsonar.login=sqp_6630dcaccf495cdb43afb14904e4f3fe0104a77f \
                -Dsonar.java.binaries=target \
                -Dsonar.coverage.exclusion=**/.mvn/**,**/src/test/**,**/model/**,**Application.java
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                sleep(8)
                timeout(time: 1, unit: 'MINUTES') {
                waitForQualityGate abortPipeline: false, credentialsId: 'SonarToken'
                    
                }
            }
        }
        
        stage('Deploy Backend') {
            steps {
               deploy adapters: [tomcat9(credentialsId: 'TomcatLogin', path: '', url: 'http://localhost:8002/')], contextPath: 'tasks-backend', war: 'target/tasks-backend.war'
            }
        }

        stage('API Tests') {
            steps {
                dir('api-test') {
                    git branch: 'main', url: 'https://github.com/Alan0170/tasks-api-test'
                    bat 'mvn test'           
                }
            }
        }

        stage('Deploy Frontend') {
            steps {
                dir ('frontend') {  
                    git branch: 'master', url: 'https://github.com/Alan0170/tasks-frontend'
                    bat 'mvn clean package'
                    deploy adapters: [tomcat9(credentialsId: 'TomcatLogin', path: '', url: 'http://localhost:8002/')], contextPath: 'tasks', war: 'target/tasks.war'
                }
            }
        }
    }
}
