FROM openjdk:8-alpine
WORKDIR /var/lib/skyfactory4

ADD https://edge.forgecdn.net/files/3565/687/SkyFactory-4_Server_4_2_4.zip /var/lib/skyfactory4/
RUN unzip SkyFactory*.zip && rm SkyFactory*.zip

COPY ./entrypoint.sh /var/lib/skyfactory4/entrypoint.sh

CMD [ "sh /var/lib/skyfactory4/entrypoint.sh" ]
