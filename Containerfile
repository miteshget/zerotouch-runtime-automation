FROM registry.access.redhat.com/ubi9/python-311
WORKDIR /app/

USER root
RUN dnf install -y sshpass
RUN chown -R ${USER_UID}:0 /app
USER ${USER_UID}

COPY ./requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt

COPY ./ansible.cfg /opt/app-root/src/.ansible.cfg
COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy collection install -vv -r /tmp/requirements.yml --collections-path "/usr/share/ansible/collections"
RUN rm /opt/app-root/src/.ansible.cfg

ENV BASE_DIR="/runner/repo"
ENV HOST="0.0.0.0"
ENV PORT=8501

# Copy ansible plugins
RUN mkdir -p /usr/share/ansible/plugins/action/
COPY ./ansible-plugins /usr/share/ansible/plugins/
COPY ./api /app/

# Copy the entrypoint script into the container
COPY ./entrypoint.sh /entrypoint.sh
# Make the entrypoint script executable and change ownership
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]