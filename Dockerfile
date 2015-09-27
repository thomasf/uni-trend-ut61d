from debian:jessie
RUN \
  apt-get update && \
  apt-get install -y build-essential pkg-config libhidapi-dev
run apt-get install -y libusb-1.0-0-dev libudev-dev
ADD . /opt/ut61d
WORKDIR /opt/ut61d
RUN cd he2325u && make clean && make
CMD ["bash", "./startdmm.sh"]
