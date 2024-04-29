FROM tonyzhang/focal-builder:5.4

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

