FROM gliderlabs/alpine:3.4

RUN \
apk-install \
curl \
openssh-client \
python \
py-boto \
py-dateutil \
py-httplib2 \
py-jinja2 \
py-paramiko \
py-pip \
py-setuptools \
py-yaml \
tar && \
pip install --upgrade pip python-keyczar && \
rm -rf /var/cache/apk/*

RUN mkdir /etc/ansible/ /ansible
RUN echo "[VPS]" >> /etc/ansible/hosts && \
echo "108.175.11.154" >> /etc/ansible/hosts

RUN \
curl -fsSL https://releases.ansible.com/ansible/ansible-2.2.2.0.tar.gz -o ansible.tar.gz && \
tar -xzf ansible.tar.gz -C ansible --strip-components 1 && \
rm -fr ansible.tar.gz /ansible/docs /ansible/examples /ansible/packaging

ADD ./Identity/LUS /root/.ssh/id_rsa
ADD ./Identity/known_hosts /root/.ssh/known_hosts
RUN  echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config
RUN chmod 400 ~/.ssh/id_rsa
RUN chmod 644 ~/.ssh/known_hosts

ADD ./entrypoint.sh /ansible/playbooks/entrypoint.sh 

RUN mkdir -p /ansible/playbooks
WORKDIR /ansible/playbooks
COPY ./playbooks/ /ansible/playbooks/


ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PATH /ansible/bin:$PATH
ENV PYTHONPATH /ansible/lib

ENTRYPOINT ["./entrypoint.sh"]