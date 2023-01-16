ARG PYTHON_IMAGE
FROM ${PYTHON_IMAGE} AS base_python

ARG repo_home
ARG pip_repo_home=${repo_home}/pip_server
ARG basic_packages=("setuptools_rust" "wheel" "cython" "numpy")

## install basic python pkg
COPY basic_requirements.txt /tmp/

# install pip2pi
RUN pip3 install --upgrade pip && \
    pip3 install pip2pi && \

## make index
    mkdir -p ${pip_repo_home} && \

## install some tool basic package
    pip3 install setuptools_rust wheel cython numpy && \

    source /etc/profile && pip2tgz ${pip_repo_home} --no-binary=:all: -r /tmp/basic_requirements.txt && \
    rm /tmp/basic_requirements.txt

## make index(simple folder)
    source /etc/profile && dir2pi ${pip_repo_home} && \

## install httpd and set home path
    yum -y install httpd

COPY s6/ /etc

RUN sed -i "s#^DocumentRoot.*#DocumentRoot \"${repo_home}\"#g" /etc/httpd/conf/httpd.conf && \
    echo -e """\n\
<Directory ${repo_home}>\n\
    AllowOverride none\n\
    Require all denied\n\
</Directory>\n\
""" >> /etc/httpd/conf/httpd.conf
