FROM qa.stratio.com/stratio/ubuntu-base:16.04
MAINTAINER Stratio QA - Team "qa@stratio.com"

COPY docker/docker-entrypoint.sh /dcos/docker-entrypoint.sh
COPY target/dcosTokenGenerator-${VERSION}-jar-with-dependencies.jar /dcos/dcosTokenGenerator.jar

RUN apt-get update && apt-get install -y build-essential chrpath libssl-dev libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev curl python-pip sshpass
RUN pip install dcoscli

RUN chmod a+x /dcos/docker-entrypoint.sh && chmod a+x /dcos/dcosTokenGenerator.jar

WORKDIR /dcos

EXPOSE 22

ENTRYPOINT ["/dcos/docker-entrypoint.sh"]
