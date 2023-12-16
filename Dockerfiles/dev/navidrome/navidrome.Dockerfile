ARG IMAGE_GO_NODEJS
FROM ${IMAGE_GO_NODEJS}

ARG TARGETARCH

ARG navidrome_tag
# ARG taglib_tag=1.12
ARG module_home
ARG navidrome_module_home=${module_home}/navidrome

ARG github_url

ENV PORT=4533
ENV ADMIN_USER=admin
ENV ADMIN_PASSWORD=admin
ENV MUSIC_FOLDER=/opt/modules/navidrome/music_folder
ENV DATA_FOLDER=/opt/modules/navidrome/data

COPY ./scripts/init-navidrome.sh /tmp
COPY ./scripts/navidrome-start.sh /usr/local/bin/navidromestart
COPY ./scripts/navidrome-stop.sh /usr/local/bin/navidromestop
COPY ./scripts/navidrome-restart.sh /usr/local/bin/navidromerestart
COPY ./config/navidrome.toml.template /tmp

RUN mkdir -p ${module_home} && cd ${module_home} && \
    
    navidrome_code_pkg=v${navidrome_tag}.tar.gz && \
    navidrome_code_folder=navidrome-${navidrome_tag} && \
    navidrome_code_url=${github_url}/navidrome/navidrome/archive/refs/tags/${navidrome_code_pkg} && \
    curl -LO ${navidrome_code_url} && tar -xzvf ${navidrome_code_pkg} && rm ${navidrome_code_pkg} && \
    
    source /etc/profile && \

    ## compile taglib
    taglib_code_folder=taglib && \
    git clone ${github_url}/taglib/taglib && cd ${taglib_code_folder} && \
    sed -i "s#url = https://github.com#url = ${github_url}#g" .gitmodules && git submodule update --init && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON && make && make install && \
    cd .. && rm -r ${taglib_code_folder} && \

    ## compile navidrome
    ### https://nova.moe/solve-go-buildvcs
    export GOFLAGS="-buildvcs=false" && \
    ### fix after start always "Received termination signal" problem
    cd ${navidrome_code_folder} && sed -i "s#.*SIGHUP.*##g" cmd/signaler_unix.go && \
    make setup && make buildall && \
    mkdir -p ${navidrome_module_home} && cp navidrome ${navidrome_module_home}/ && \
    cd .. && rm -r ${navidrome_code_folder} && \

    ## compile ffmpeg
    git clone ${github_url}/FFmpeg/FFmpeg && cd FFmpeg && \
    yum -y install diffutils && \
    ./configure --prefix=/usr --disable-x86asm && make && make install && \
    cd .. && rm -r FFmpeg && \

    ## copy scripts
    navidrome_scripts_home=${navidrome_module_home}/scripts && \
    mkdir -p ${navidrome_scripts_home} && \
    cp /tmp/init-navidrome.sh ${navidrome_scripts_home} && cp /tmp/navidrome.toml.template ${navidrome_module_home} && \

    sed -i "s#{navidrome_module_home}#${navidrome_module_home}#g" ${navidrome_scripts_home}/init-navidrome.sh && \

    sed -i "s#{navidrome_module_home}#${navidrome_module_home}#g" /usr/local/bin/navidromestart && \
    chmod +x /usr/local/bin/navidromestart && chmod +x /usr/local/bin/navidromestop && chmod +x /usr/local/bin/navidromerestart && \

    echo "sh ${navidrome_scripts_home}/init-navidrome.sh && navidromestart" >> /init_service