FROM node:8-stretch
LABEL maintainer "David J. M. Karlsen <david@davidkarlsen.com>"
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
	sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
	apt-get update && \
	apt-get -y install google-chrome-stable vim less psmisc && \
	apt-get clean && \
	rm -rf /var/cache/apt

RUN arch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" && \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.10/gosu-$arch" && \
	chmod a+x /usr/local/bin/gosu

RUN wget -q -O - "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64" |tar xjv -C /opt

RUN yarn global add @angular/cli sonarqube-scanner@latest retire && \
	ng set --global packageManager=yarn && \
	which ng && \
	ng version && \
	npm version && \
	yarn --version && \
	yarn config list

ENV CHROME_BIN=/usr/bin/google-chrome
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=/opt/firefox:${PATH}

# Specify any standard chown format (uid, uid:gid), default to root:root
ENV GOSU_USER 0:0
# Specify any space delimited directories that should be chowned to GOSU_USER
ENV GOSU_CHOWN /home/node
COPY gosu-entrypoint.sh /
RUN chmod +x /gosu-entrypoint.sh
ENTRYPOINT ["/gosu-entrypoint.sh"]
