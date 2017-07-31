FROM centos

EXPOSE 80 443

WORKDIR /opt

RUN useradd -s /bin/false pmm
RUN yum -y install epel-release && yum -y install ansible

COPY nginx.repo /etc/yum.repos.d/nginx.repo
RUN gpg --keyserver pgp.mit.edu --recv-keys 0xabf5bd827bd9bf62
RUN gpg -a --export 7bd9bf62 > /root/nginx.key
RUN rpm --import /root/nginx.key

COPY playbook-install.yml /opt/playbook-install.yml
RUN ansible-playbook -vvv -i 'localhost,' -c local /opt/playbook-install.yml

COPY supervisord.conf /etc/supervisord.d/pmm.ini
COPY playbook-init.yml /opt/playbook-init.yml
RUN ansible-playbook -vvv -i 'localhost,' -c local /opt/playbook-init.yml

COPY entrypoint.sh /opt

CMD ["/opt/entrypoint.sh"]
