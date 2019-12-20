FROM tensorflow/tensorflow:latest-py3

RUN apt-get update && apt-get install -y \
   apt-utils \
   software-properties-common \
   git \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --upgrade pip

# install jupyter
#RUN pip install jupyter matplotlib \
#&& pip install jupyter_http_over_ws \
#&& jupyter serverextension enable --py jupyter_http_over_ws

#
# Source: https://github.com/uber/ludwig/blob/master/Dockerfile
#
RUN git clone --depth=1 https://github.com/uber/ludwig.git \
    && cd ludwig/ \
    && pip install -r requirements.txt \
    && pip install -r requirements_image.txt \
    && pip install -r requirements_serve.txt \
    && pip install -r requirements_viz.txt \
    && python setup.py install

#     && pip install -r requirements_text.txt \
#    && pip install -r requirements_audio.txt \

WORKDIR /data

ENTRYPOINT ["ludwig"]
