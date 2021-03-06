FROM python:3.5

ENV PYTHONUNBUFFERED 1


# Build-time metadata as defined at http://label-schema.org
ARG OPACSSM_BUILD_DATE
ARG OPACSSM_VCS_REF
ARG OPACSSM_WEBAPP_VERSION

ENV OPACSSM_BUILD_DATE ${OPACSSM_BUILD_DATE}
ENV OPACSSM_VCS_REF ${OPACSSM_VCS_REF}
ENV OPACSSM_WEBAPP_VERSION ${OPACSSM_WEBAPP_VERSION}

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="OPACSSM WebApp - production build" \
      org.label-schema.description="OPACSSM WebApp main app" \
      org.label-schema.url="https://github.com/scieloorg/opac_ssm/" \
      org.label-schema.vcs-ref=$OPACSSM_VCS_REF \
      org.label-schema.vcs-url="https://github.com/scieloorg/opac_ssm/" \
      org.label-schema.vendor="SciELO" \
      org.label-schema.version=$OPACSSM_WEBAPP_VERSION \
      org.label-schema.schema-version="1.0"

# Requirements have to be pulled and installed here, otherwise caching won't work
COPY ./requirements /requirements

RUN pip install -r /requirements/production.txt \
    && pip install -r /requirements/test.txt \
    && groupadd -r django \
    && useradd -r -g django django

COPY . /app

COPY ./entrypoint.sh /entrypoint.sh
COPY ./gunicorn.sh /gunicorn.sh
COPY ./start-grpc.sh /start-grpc.sh

RUN sed -i 's/\r//' /entrypoint.sh \
    && sed -i 's/\r//' /gunicorn.sh \
    && sed -i 's/\r//' /start-grpc.sh \
    && chmod +x /entrypoint.sh \
    && chmod +x /gunicorn.sh \
    && chmod +x /start-grpc.sh \
    && chown django /entrypoint.sh \
    && chown django /gunicorn.sh \
    && chown django /start-grpc.sh

WORKDIR /app

RUN chown -R django /app

USER django

ENTRYPOINT ["/entrypoint.sh"]
