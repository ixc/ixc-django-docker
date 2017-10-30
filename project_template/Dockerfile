FROM buildpack-deps:xenial

# Set your project name here, and a different directory if needed (unlikely)
ENV PROJECT_NAME=project_template
ENV PROJECT_DIR=/opt/${PROJECT_NAME}/

RUN apt-get update \
    && apt-get upgrade -y --no-install-recommends \
    && apt-get install -y --no-install-recommends \
        apt-utils \
        gettext \
        gnupg2 \
        jq \
        locales \
        nano \
        nginx \
        apache2-utils \
        postgresql-client \
        python-dev \
        pv \
        vim-tiny \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

ENV DOCKERIZE_VERSION=0.4.0
RUN wget -nv -O - "https://github.com/jwilder/dockerize/releases/download/v${DOCKERIZE_VERSION}/dockerize-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz" | tar -xz -C /usr/local/bin/ -f -

ENV NODE_VERSION=4.4.2
RUN wget -nv -O - "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" | tar -Jx -C /opt/ -f -
RUN ln -s "/opt/node-v${NODE_VERSION}-linux-x64/bin/node" /usr/local/bin/
RUN ln -s "/opt/node-v${NODE_VERSION}-linux-x64/bin/npm" /usr/local/bin/

ENV PYTHON_PIP_VERSION=9.0.1
RUN wget -nv -O - https://bootstrap.pypa.io/get-pip.py | python - "pip==${PYTHON_PIP_VERSION}"

ENV TINI_VERSION=0.14.0
RUN wget -nv -O /usr/local/bin/tini "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static"
RUN chmod +x /usr/local/bin/tini

WORKDIR /opt/git-secret/

ENV GIT_SECRET_VERSION=0.2.1
RUN git clone https://github.com/sobolevn/git-secret.git /opt/git-secret/ \
    && git checkout "v$GIT_SECRET_VERSION" \
    && make build \
    && PREFIX=/usr/local make install

WORKDIR ${PROJECT_DIR}

COPY package.json ${PROJECT_DIR}
RUN npm install && rm -rf /root/.npm
RUN md5sum package.json > package.json.md5
ENV PATH=${PROJECT_DIR}node_modules/.bin:$PATH

COPY bower.json ${PROJECT_DIR}
RUN bower install --allow-root && rm -rf /root/.cache/bower
RUN md5sum bower.json > bower.json.md5

ENV PIP_DISABLE_PIP_VERSION_CHECK=on
ENV PIP_SRC=/opt
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONHASHSEED=random
ENV PYTHONWARNINGS=ignore

COPY requirements.txt ${PROJECT_DIR}
RUN bash -c 'pip install --no-cache-dir -r <(grep -v setuptools requirements.txt)'  # Unpin setuptools dependencies. See: https://github.com/pypa/pip/issues/4264
RUN md5sum requirements.txt > requirements.txt.md5


COPY setup.py ${PROJECT_DIR}
RUN pip install --no-cache-dir -e .

ENV ELASTICSEARCH_ADDRESS=elasticsearch:9200
ENV PATH=${PROJECT_DIR}bin:$PATH
ENV PGHOST=postgres
ENV PGUSER=postgres
ENV REDIS_ADDRESS=redis:6379

ENTRYPOINT ["tini", "--", "entrypoint.sh"]
CMD ["bash.sh"]

COPY . ${PROJECT_DIR}

# Fix password pass-through for git-secret and gpg2
RUN echo "allow-loopback-pinentry" > .gnupg/gpg-agent.conf
RUN echo "pinentry-mode loopback" > .gnupg/gpg.conf

RUN manage.py collectstatic --noinput --verbosity=0

RUN manage.py compress --verbosity=0
