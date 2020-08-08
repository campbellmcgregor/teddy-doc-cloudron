FROM cloudron/base:2.0.0@sha256:f9fea80513aa7c92fe2e7bf3978b54c8ac5222f47a9a32a7f8833edf0eb5a4f4

EXPOSE 8080 

RUN apt-get update && \
    apt-get -y -q install openjdk-11-jdk \
    ffmpeg mediainfo tesseract-ocr tesseract-ocr-fra tesseract-ocr-ita tesseract-ocr-kor tesseract-ocr-rus tesseract-ocr-ukr tesseract-ocr-spa \
    tesseract-ocr-ara tesseract-ocr-hin tesseract-ocr-deu tesseract-ocr-pol tesseract-ocr-jpn tesseract-ocr-por tesseract-ocr-tha \
    tesseract-ocr-jpn tesseract-ocr-chi-sim tesseract-ocr-chi-tra tesseract-ocr-nld tesseract-ocr-tur tesseract-ocr-heb tesseract-ocr-hun && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/
ENV JAVA_OPTS -Duser.timezone=Europe/London -Dfile.encoding=UTF-8 -Xmx1024m
ENV DOCS_VERSION 1.8

# Download and install Jetty
ENV JETTY_VERSION 9.4.12.v20180830
RUN mkdir -p /app/pkg/ /app/data /app/code
RUN wget -nv -O /tmp/jetty.tar.gz \
    "https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${JETTY_VERSION}/jetty-distribution-${JETTY_VERSION}.tar.gz" \
    && tar xzf /tmp/jetty.tar.gz -C /app/code \
    && mv /app/code/jetty* /app/code/jetty \
    && useradd jetty -U -s /bin/false \
    && chown -R jetty:jetty /app/code/jetty
WORKDIR /app/code/jetty
RUN chmod +x bin/jetty.sh

# Init configuration
COPY jetty /app/code
ENV JETTY_HOME /app/code/jetty
ENV JAVA_OPTIONS -Xmx512m

RUN git clone https://github.com/sismics/docs.git /app/code/teddy
RUN wget https://github.com/sismics/docs/releases/download/v1.8/docs-web-${DOCS_VERSION}.war -O /app/code/jetty/webapps/docs.war

COPY start.sh /app/code/
RUN chmod +x /app/code/start.sh
# Remove the embedded javax.mail jar from Jetty
RUN rm -f /app/code/jetty/lib/mail/javax.mail.glassfish-*.jar

COPY docs.xml /app/code/jetty/webapps/docs.xml
#COPY docs-web/target/docs-web-*.war /app/code/jetty/webapps/docs.war
RUN chown -R cloudron:cloudron /app/code && \
    chown -R cloudron:cloudron /app/data

CMD ["/app/code/start.sh"]