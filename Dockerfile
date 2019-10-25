FROM nvidia/cuda:10.1-base-ubuntu18.04
# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8
LABEL com.nvidia.volumes.needed="nvidia_driver"

RUN echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         vim \
         ca-certificates \
         python-qt4 \
         libjpeg-dev \
         zip \
         unzip \
         libpng-dev &&\
     rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV PYTHON_VERSION=3.6

RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh && \
    /opt/conda/bin/conda install conda-build

ENV PATH=$PATH:/opt/conda/bin/
ENV USER fastai

# Create Enviroment
COPY environment.yaml /enviroment.yaml
RUN conda env create -f enviroment.yaml

WORKDIR /notebooks

# Activate Source
CMD source activate fastai
CMD source ~/.bashrc

RUN chmod -R a+w /notebooks
WORKDIR /notebooks

# Clone course-v3
RUN git clone https://github.com/fastai/course-v3.git

COPY config.yaml /root/.fastai/config.yaml
COPY run.sh /run.sh

# Only applies to fastai release 1.0.52
RUN pip install nbconvert==5.4.1

# Open Port 8888 for Jupyter
EXPOSE 8888

CMD ["/run.sh"]
