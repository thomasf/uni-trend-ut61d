from debian:jessie
RUN \
  apt-get update && \
  apt-get install -y build-essential pkg-config libhidapi-dev
ADD . /opt/ut61d
WORKDIR /opt/ut61d
RUN cd he2325u && make
CMD ["bash", "./startdmm.sh"]
