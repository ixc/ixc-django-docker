# Avoid long build times by using an existing base image.
ARG IMAGE_TAG=master
FROM "interaction/project_template:${IMAGE_TAG}"

# Reinstall dependencies, if changed.
COPY requirements.txt .
RUN entrypoint.sh pip-install.sh

# Launch entrypoint.sh automatically with bash.
RUN echo 'source entrypoint.sh' >> /root/.bashrc

ENTRYPOINT ["tini", "--"]
CMD ["sleep", "infinity"]
