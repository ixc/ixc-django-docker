FROM buildpack-deps:xenial

RUN apt-get update \
    && apt-get upgrade -y --no-install-recommends \
    && apt-get install -y --no-install-recommends \
        apt-utils \
        locales \
        nano \
        nginx \
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

WORKDIR /opt/project_template/

COPY package.json /opt/project_template/
RUN npm install && rm -rf /root/.npm
RUN md5sum package.json > package.json.md5
ENV PATH=/opt/project_template/node_modules/.bin:$PATH

COPY bower.json /opt/project_template/
RUN bower install --allow-root && rm -rf /root/.cache/bower
RUN md5sum bower.json > bower.json.md5

ENV PIP_DISABLE_PIP_VERSION_CHECK=on
ENV PIP_SRC=/opt
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONHASHSEED=random
ENV PYTHONWARNINGS=ignore

COPY requirements.txt /opt/project_template/
RUN bash -c 'pip install --no-cache-dir -r <(grep -v setuptools requirements.txt)'  # Unpin setuptools dependencies. See: https://github.com/pypa/pip/issues/4264
RUN md5sum requirements.txt > requirements.txt.md5

COPY setup.py /opt/project_template/
RUN pip install --no-cache-dir -e .

ENV ELASTICSEARCH_ADDRESS=elasticsearch:9200
ENV PATH=/opt/project_template/bin:$PATH
ENV PGHOST=postgres
ENV PGUSER=postgres
ENV PROJECT_DIR=/opt/project_template
ENV PROJECT_NAME=project_template
ENV REDIS_ADDRESS=redis:6379

ENTRYPOINT ["tini", "--", "entrypoint.sh"]
CMD ["bash.sh"]

COPY . /opt/project_template/

RUN manage.py collectstatic --noinput --verbosity=0
RUN manage.py compress --verbosity=0
