FROM ubuntu:16.04
LABEL maintainer caffe-maint@googlegroups.com

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        wget \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        python-dev \
        python-numpy \
        python-pip \
        python-setuptools \
        python-scipy && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://bootstrap.pypa.io/pip/2.7/get-pip.py && \
    python get-pip.py && \
    pip install --upgrade setuptools
RUN pip install --upgrade pip


WORKDIR /opt/
ENV DORN_ROOT=/opt/DORN
ENV CAFFE_ROOT=/opt/DORN/caffe
COPY ./ $DORN_ROOT


WORKDIR $CAFFE_ROOT/python
RUN for req in $(cat requirements.txt) pydot; do pip install $req; done
WORKDIR $CAFFE_ROOT
RUN mkdir build
WORKDIR $CAFFE_ROOT/build
RUN cmake .. -DCPU_ONLY=1
RUN make -j"$(nproc)"

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$CAFFE_ROOT/pylayer:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

WORKDIR /opt/
RUN mkdir result
RUN pip install gdown
RUN pip install opencv-python==4.2.0.32
RUN gdown 180QRn5su1Yf5d-WNqE0jELPNuOpQMjNR
RUN gdown 1PkxkzWwZthjnJGtaPlTS5qTrj-Tka7eX
RUN mv cvpr_kitti.caffemodel $DORN_ROOT/models/KITTI/
RUN mv cvpr_nyuv2.caffemodel $DORN_ROOT/models/NYUV2/
WORKDIR $DORN_ROOT