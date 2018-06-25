FROM buildpack-deps:xenial

# SYSTEM ######################################################################

RUN apt-get update \
    && apt-get upgrade -y --no-install-recommends \
    && apt-get install -y --no-install-recommends \
        apache2-utils \
        apt-utils \
        bsdmainutils \
        gettext  \
        htop \
        jq \
        less \
        locales \
        nano \
        nginx \
        postgresql-client \
        pv \
        python2.7-dev \
        python3.5-dev \
        supervisor \
        vim-tiny \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

ENV DOCKERIZE_VERSION=0.6.1
RUN wget -nv -O - "https://github.com/jwilder/dockerize/releases/download/v${DOCKERIZE_VERSION}/dockerize-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz" | tar -xz -C /usr/local/bin/ -f -

ENV LOGENTRIES_VERSION=1.4.43
RUN echo 'deb http://rep.logentries.com/ xenial main' > /etc/apt/sources.list.d/logentries.list
RUN apt-get update \
    && apt-get install -y --allow-unauthenticated --no-install-recommends \
        logentries="${LOGENTRIES_VERSION}" \
    && rm -rf /var/lib/apt/lists/*

ENV NODE_VERSION=6.12.0
RUN wget -nv -O - "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" | tar -Jx -C /opt/ -f -
RUN ln -s "/opt/node-v${NODE_VERSION}-linux-x64/bin/node" /usr/local/bin/
RUN ln -s "/opt/node-v${NODE_VERSION}-linux-x64/bin/npm" /usr/local/bin/

ENV PYTHON_VERSION=3.5
RUN ln -fs "python${PYTHON_VERSION}" /usr/bin/python

ENV PYTHON_PIP_VERSION=9.0.1
RUN wget -nv -O - https://bootstrap.pypa.io/get-pip.py | python - "pip==${PYTHON_PIP_VERSION}"

ENV TINI_VERSION=0.16.1
RUN wget -nv -O /usr/local/bin/tini "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static"
RUN chmod +x /usr/local/bin/tini

# PROJECT #####################################################################

ENV PROJECT_NAME=project_template
ENV PROJECT_DIR="/opt/${PROJECT_NAME}/"

WORKDIR "${PROJECT_DIR}"

COPY package.json "${PROJECT_DIR}"
RUN npm install && rm -rf /root/.npm
RUN md5sum package.json > package.json.md5
ENV PATH="${PROJECT_DIR}node_modules/.bin:$PATH"

COPY bower.json "${PROJECT_DIR}"
RUN bower install --allow-root && rm -rf /root/.cache/bower
RUN md5sum bower.json > bower.json.md5

ENV PIP_DISABLE_PIP_VERSION_CHECK=on
ENV PIP_SRC=/opt
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONHASHSEED=random
ENV PYTHONWARNINGS=ignore

COPY requirements.txt "${PROJECT_DIR}"
RUN pip install --no-cache-dir -r requirements.txt
RUN md5sum requirements.txt > requirements.txt.md5

ENV PATH="${PROJECT_DIR}bin:$PATH"

ENTRYPOINT ["tini", "--", "entrypoint.sh"]
CMD ["bash.sh"]

COPY . ${PROJECT_DIR}

RUN entrypoint.sh compile-sass.sh  # Must come before collectstatic
RUN entrypoint.sh manage.py collectstatic --noinput --verbosity=0
RUN entrypoint.sh manage.py compress --verbosity=0
