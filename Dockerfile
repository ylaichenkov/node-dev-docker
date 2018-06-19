FROM node:9.8.0-stretch
LABEL maintainer "David J. M. Karlsen <david@davidkarlsen.com>"
ENV ANGULAR_CLI_VERSION=1.7.3 OWASP_DEPENDENCY_CHECK_VERSION=3.1.1 SONAR_CLI_VERSION=3.0.3.778

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
	sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
	apt-get update && \
	apt-get -y install google-chrome-stable vim less psmisc unzip net-tools libdbus-glib-1-2 && \
	apt-get -y dist-upgrade && \
	apt-get clean && \
	rm -rf /var/cache/apt && \
	arch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" && \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.10/gosu-$arch" && \
	chmod a+x /usr/local/bin/gosu

ENV CHROME_BIN=/usr/bin/google-chrome \
	GOSU_USER="0:0" \
	GOSU_CHOWN="/home/node /usr/local/dependency-check/data" 

RUN npm install -g \
    npm \
    protractor \
    webdriver-manager && \
    webdriver-manager update

COPY gosu-entrypoint.sh showversions.sh /
#RUN chmod +x /gosu-entrypoint.sh && \
#	/showversions.sh
RUN chmod +x /gosu-entrypoint.sh

ENTRYPOINT ["/gosu-entrypoint.sh"]
