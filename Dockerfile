FROM tomcat:9.0.98-jdk17-corretto-al2

ARG WAR_FILE
ARG CONTEXT

COPY ${WAR_FILE} /usr/local/tomcat/webapps/${CONTEXT}.war
