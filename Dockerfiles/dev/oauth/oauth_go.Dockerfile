ARG GO_IMAGE
FROM ${GO_IMAGE}

# ENV CLIENT_PORT=9094
# ENV SERVER_PORT=9096
ENV HOST "localhost"
ENV HOST_SERVER_PORT "9096"
ENV HOST_CLIENT_PORT "9094"

ARG module_home=/opt/modules
ARG github_url=https://github.com
ARG branch=dev

# compile
## https://github.com/smiecj/go-oauth2
RUN mkdir -p ${module_home} && cd ${module_home} && git clone ${github_url}/smiecj/go-oauth2 -b ${branch} && \
    source /etc/profile && cd go-oauth2 && make build

## copy oauth start and stop script
COPY ./scripts/oauth-start.sh /usr/local/bin/oauthstart
COPY ./scripts/oauth-stop.sh /usr/local/bin/oauthstop
COPY ./scripts/oauth-restart.sh /usr/local/bin/oauthrestart
RUN sed -i "s#{oauth_module_home}#${module_home}/go-oauth2#g" /usr/local/bin/oauthstart && \
    sed -i "s#{oauth_module_home}#${module_home}/go-oauth2#g" /usr/local/bin/oauthstop && \
    chmod +x /usr/local/bin/oauthstart && chmod +x /usr/local/bin/oauthstop && chmod +x /usr/local/bin/oauthrestart

## init script
RUN echo "oauthstart" >> /init_service
