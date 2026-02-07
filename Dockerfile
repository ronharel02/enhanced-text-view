FROM debian:latest

WORKDIR /home

RUN apt-get update && apt-get install -y \
	zip                          \
	openssl                      \
	chromium                     \
	nodejs                       \
	npm                          \
	jq

ADD package.json /home/package.json
RUN npm install
ENV PATH="$PATH:/home/node_modules/.bin"

VOLUME [ "/secrets", "/dist", "/extension-pack" ]
ADD build_packages.sh /entrypoint.sh

ENTRYPOINT ["bash", "/entrypoint.sh"]
