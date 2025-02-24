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
                sleep(12)
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

        stage('Functional Tests') {
            steps {
                dir('functional-test') {
                    git branch: 'master', url: 'https://github.com/Alan0170/tasks-functional-tests'
                    bat 'mvn test'         
                }
            }
        }

        stage('Deploy Production') {
            steps {
                bat 'docker-compose build'
                bat 'docker-compose up -d'
            }
        }

        stage('Health Check') {
            steps {
                sleep(12)
                dir('functional-test') {
                    bat 'mvn verify -Dskip.surefire.tests'      
                }
            }
        }
    }

    post {
        always {
            junit allowEmptyResults: true, stdioRetention: '', testResults: 'target/surefire-reports/*.xml, api-test/target/surefire-reports/*.xml, functional-test/target/surefire-reports/*.xml, functional-test/target/failsafe-reports/*.xml'
            archiveArtifacts artifacts: 'target/tasks-backend.war, frontend/target/tasks.war', followSymlinks: false
        }
        unsuccessful {
            emailext attachLog: true, body: 'See the attached log for details', subject: 'Build $BUILD_NUMBER has failed', to: 'alan.msp22@gmail.com'
        }
        fixed {
            emailext attachLog: true, body: 'See the attached log for details', subject: 'Build $BUILD_NUMBER is fine!', to: 'alan.msp22@gmail.com'
        }
    }
}
