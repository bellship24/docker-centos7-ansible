FROM centos:7
#LABEL maintainer="Jeff Geerling"
LABEL maintainer="bellship24"
ENV container=docker

ENV pip_packages "ansible"

# Install systemd -- See https://hub.docker.com/_/centos/
RUN yum -y update; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install requirements.
# RUN yum makecache fast \
RUN \ 
 yum -y install deltarpm epel-release initscripts \
 && yum -y update \
 && yum -y install \
      sudo \
      which \
      python3-pip \
 && yum clean all

# Install Ansible via Pip.
ENV LC_CTYPE "en_US.UTF-8"
RUN  pip3 install -U pip \
  && pip3 install $pip_packages

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]


##### create ansible user and set NOPASSWD by bellship24
RUN groupadd -g 9999 ansible
RUN useradd -rm -d /home/ansible -s /bin/bash -g 9999 -G ansible -u 9999 ansible
RUN echo 'ansible ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
#####
