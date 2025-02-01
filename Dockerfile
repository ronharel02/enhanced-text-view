FROM debian:latest

WORKDIR /home

RUN apt update && apt install -y \
    zip                          \
    openssl                      \
    chromium                     \
    nodejs                       \
    npm

ADD package.json /home/package.json
RUN npm install
ENV PATH="$PATH:/home/node_modules/.bin"

VOLUME [ "/secrets", "/dist", "/extension-pack" ]
ADD build_packages.sh /entrypoint.sh

CMD ["bash", "/entrypoint.sh"]
