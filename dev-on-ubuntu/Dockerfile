FROM ubuntu:20.04

# System Setup ================================================================
# RUN ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
RUN apt update -y && apt upgrade -y
# Basic
RUN apt install -y \
    apt-utils \
    language-pack-ja \
    gcc g++ gfortran make\
    wget curl git \
    vim emacs

# Node
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt install -y nodejs
# Python
ARG PYTHON_VERSION=3.8
RUN apt install -y python3 python3-pip python3-venv
RUN apt install -y python${PYTHON_VERSION} \
                   python${PYTHON_VERSION}-dev \
                   python${PYTHON_VERSION}-venv
# User ========================================================================
ARG USER_NAME=developer
ARG USER_PASSWORD=developer
# user generate
RUN useradd -m ${USER_NAME} 
RUN echo ${USER_NAME}:${USER_PASSWORD} | chpasswd 
RUN chsh -s /bin/bash ${USER_NAME}
USER ${USER_NAME}
# python
ARG VIRTUAL_ENV=py38
RUN python${PYTHON_VERSION} -m venv /home/${USER_NAME}/.venv/${VIRTUAL_ENV}
RUN /home/${USER_NAME}/.venv/${VIRTUAL_ENV}/bin/python -m pip install --upgrade pip wheel setuptools
RUN /home/${USER_NAME}/.venv/${VIRTUAL_ENV}/bin/python -m pip install jupyter jupyterlab \
    autopep8 yapf black pylint rope jedi flake8 \
    numpy pandas scipy scikit-learn \
    matplotlib seaborn \
    xlrd openpyxl
RUN echo "" >> ~/.bashrc
RUN echo source ~/.venv/${VIRTUAL_ENV}/bin/activate >> ~/.bashrc
# jupyter
RUN /home/${USER_NAME}/.venv/${VIRTUAL_ENV}/bin/jupyter lab --generate-config
RUN echo c.ServerApp.ip = "'0.0.0.0'" >> ~/.jupyter/jupyter_lab_config.py
RUN echo c.ServerApp.open_browser = False >> ~/.jupyter/jupyter_lab_config.py
RUN echo c.ServerApp.port = 8888 >> ~/.jupyter/jupyter_lab_config.py
RUN echo c.ServerApp.token = "''" >> ~/.jupyter/jupyter_lab_config.py
ARG JUPYTER_PASSWORD
RUN /home/${USER_NAME}/.venv/${VIRTUAL_ENV}/bin/python -c \
    'from jupyter_server.auth import passwd;print(passwd("'"${JUPYTER_PASSWORD}"'"))' | \
    awk '{print "c.ServerApp.password = \""$1"\""}' >> ~/.jupyter/jupyter_lab_config.py
EXPOSE 8888

USER root
CMD ["/sbin/init"]