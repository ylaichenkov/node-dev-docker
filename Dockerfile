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
	chmod a+x /usr/local/bin/gosu && \
	wget -q -O - "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64" |tar xjv -C /opt && \
	ng set --global packageManager=yarn && \
	wget http://dl.bintray.com/jeremy-long/owasp/dependency-check-${OWASP_DEPENDENCY_CHECK_VERSION}-release.zip -O /tmp/owasp-dep-check.zip && \
	unzip /tmp/owasp-dep-check.zip -d /usr/local && \
	rm /tmp/owasp-dep-check.zip && \
	wget https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_CLI_VERSION}-linux.zip -O /tmp/sonar.zip && \
	mkdir -p /home/node/.sonar/native-sonar-scanner && \
	unzip /tmp/sonar.zip -d /home/node/.sonar/native-sonar-scanner && \
	rm /tmp/sonar.zip

ENV CHROME_BIN=/usr/bin/google-chrome \
	PATH="/opt/firefox:/usr/local/dependency-check/bin:${PATH}" \
	GOSU_USER="0:0" \
	GOSU_CHOWN="/home/node /usr/local/dependency-check/data" 

RUN npm install -g \
    npm \
    protractor \
    webdriver-manager && \
    webdriver-manager update && \
	chown -R node:node /home/node /usr/local/dependency-check/data && \
	chmod -R a+w /usr/local/dependency-check/data

COPY gosu-entrypoint.sh showversions.sh /
#RUN chmod +x /gosu-entrypoint.sh && \
#	/showversions.sh
RUN chmod +x /gosu-entrypoint.sh

ENTRYPOINT ["/gosu-entrypoint.sh"]
