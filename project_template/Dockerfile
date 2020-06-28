FROM interaction/buildpack-deps:focal

ENV NODE_VERSION=12.18.1
RUN wget -nv -O - "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" | tar -Jx -C /opt/ -f -
RUN ln -s "/opt/node-v${NODE_VERSION}-linux-x64/bin/node" /usr/local/bin/
RUN ln -s "/opt/node-v${NODE_VERSION}-linux-x64/bin/npm" /usr/local/bin/

ENV PROJECT_DIR=/opt/project_template
ENV PYTHON_VERSION=python3.8

ENV PIP_DISABLE_PIP_VERSION_CHECK=on
ENV PIP_SRC="${PROJECT_DIR}/src"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONHASHSEED=random
ENV PYTHONWARNINGS=ignore

ENV PYTHON_PIP_VERSION=20.1.1
RUN wget -nv -O - https://bootstrap.pypa.io/get-pip.py | ${PYTHON_VERSION} - "pip==${PYTHON_PIP_VERSION}"

WORKDIR "${PROJECT_DIR}"

COPY package.json package-lock.json "${PROJECT_DIR}/"
RUN npm ci --unsafe-perm && rm -rf /root/.npm
RUN md5sum package.json > package.json.md5
ENV PATH="${PROJECT_DIR}/node_modules/.bin:$PATH"

COPY bower.json "${PROJECT_DIR}"
RUN bower install --allow-root && rm -rf /root/.cache/bower
RUN md5sum bower.json > bower.json.md5

COPY requirements.txt "${PROJECT_DIR}"
RUN pip install --no-cache-dir -r requirements.txt
RUN md5sum requirements.txt > requirements.txt.md5

ENTRYPOINT ["tini", "--", "entrypoint.sh"]
CMD ["bash.sh"]

COPY . "${PROJECT_DIR}"

RUN entrypoint.sh npm run build --if-present
