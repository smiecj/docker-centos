FROM centos_python AS base_python

ARG repo_home=/home/repo/pip_server
ARG basic_packages=("setuptools_rust" "wheel" "cython" "numpy")

# install pip2pi
RUN pip3 install --upgrade pip
RUN pip3 install pip2pi

## make index
RUN mkdir -p $repo_home

## install some tool basic package
RUN pip3 install setuptools_rust wheel cython numpy

## install basic python pkg
COPY basic_requirements.txt /tmp/
RUN source /etc/profile && pip2tgz ${repo_home} --no-binary=:all: -r /tmp/basic_requirements.txt
RUN rm /tmp/basic_requirements.txt

## make index(simple folder)
RUN source /etc/profile && dir2pi $repo_home

## install httpd and set home path
RUN yum -y install httpd
COPY s6/ /etc

RUN sed -i "s#^DocumentRoot.*#DocumentRoot \"$repo_home\"#g" /etc/httpd/conf/httpd.conf
RUN echo -e """\n\
<Directory $repo_home>\n\
    AllowOverride none\n\
    Require all denied\n\
</Directory>\n\
""" >> /etc/httpd/conf/httpd.conf
