FROM quintenk/jdk7-oracle
2
MAINTAINER Quinten Krijger "qkrijger@gmail.com"
3
 
4
RUN apt-get -y install tomcat7
5
RUN echo "JAVA_HOME=/usr/lib/jvm/java-7-oracle" >> /etc/default/tomcat7
6
EXPOSE 8080
7
CMD service tomcat7 start && tail -f /var/lib/tomcat7/logs/catalina.out
