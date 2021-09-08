FROM ubuntu:20.04

# System Setup ================================================================
RUN sed -i -e 's/http:\/\/archive.ubuntu/http:\/\/jp.archive.ubuntu/g' /etc/apt/sources.list
RUN apt update -y && apt upgrade -y && rm -rf /var/lib/apt/lists/*
# Basic
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update -y && apt install -y \
    sudo apt-utils net-tools tzdata \
    wget curl git \
    gcc g++ gfortran golang make \
    vim \
    supervisor openssh-server \
    xrdp lxqt-core \
    firefox \
    && \
    unset DEBIAN_FRONTEND && \
    rm -rf /var/lib/apt/lists/*

# Node
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt install -y nodejs

# Python
ARG PYTHON_VERSION=3.9
RUN apt install -y python3-pip \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv

# Language
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update -y && apt install -y \
    ibus-mozc language-pack-ja language-pack-ja-base\
    fonts-noto fonts-noto-cjk \
    fonts-takao fonts-roboto \
    && \
    unset DEBIAN_FRONTEND && \
    rm -rf /var/lib/apt/lists/*


# RUN update-locale LANG=ja_JP.UTF8

# sshd serverconfig -----------------------------------------------------------
RUN mkdir /usr/local/setup
COPY ./root_setup_scripts/* /usr/local/setup/
RUN bash /usr/local/setup/install_vscode.sh
RUN bash /usr/local/setup/install_google-chrome.sh
RUN bash /usr/local/setup/setup_xrdp.sh
RUN mkdir /var/run/sshd

RUN sed -i -e 's/http:\/\/jp.archive.ubuntu/http:\/\/archive.ubuntu/g' /etc/apt/sources.list

# User ========================================================================
ARG USER_NAME=developer
ARG USER_PASSWORD=developer
# user generate
RUN useradd -m ${USER_NAME} && \
    echo ${USER_NAME}:${USER_PASSWORD} | chpasswd && \
    chsh -s /bin/bash ${USER_NAME}
USER ${USER_NAME}

# gui system setting
RUN mkdir /home/${USER_NAME}/.setup
COPY ./user_setup_scripts/* /home/${USER_NAME}/.setup
RUN sh /home/${USER_NAME}/.setup/setup_ibus.sh
RUN echo 'startlxqt' > /home/${USER_NAME}/.xsessionrc
RUN echo 'export DONT_PROMPT_WSL_INSTALL=1' >> /home/${USER_NAME}/.bashrc
RUN sh /home/${USER_NAME}/.setup/install_vscode-extensions.sh


# python
ARG VIRTUAL_ENV=py39
RUN python${PYTHON_VERSION} -m venv /home/${USER_NAME}/.venv/${VIRTUAL_ENV} && \
    echo "" >> ~/.bashrc && \
    echo source ~/.venv/${VIRTUAL_ENV}/bin/activate >> ~/.bashrc
RUN /home/${USER_NAME}/.venv/${VIRTUAL_ENV}/bin/python -m pip install --upgrade pip wheel setuptools && \
    /home/${USER_NAME}/.venv/${VIRTUAL_ENV}/bin/python -m pip install jupyter jupyterlab \
    autopep8 yapf pylint rope jedi flake8 \
    numpy pandas scipy scikit-learn statsmodels sympy \
    matplotlib seaborn bokeh \
    openpyxl xlrd \
    sphinx sphinx_rtd_theme \
    sqlalchemy \
    pytest pytest-html pytest-cov \
    tensorflow qiskit

# jupyter
RUN /home/${USER_NAME}/.venv/${VIRTUAL_ENV}/bin/jupyter lab --generate-config && \
    echo c.ServerApp.ip = "'0.0.0.0'" >> ~/.jupyter/jupyter_lab_config.py && \
    echo c.ServerApp.open_browser = False >> ~/.jupyter/jupyter_lab_config.py && \
    echo c.ServerApp.port = 8888 >> ~/.jupyter/jupyter_lab_config.py && \
    echo c.ServerApp.token = "''" >> ~/.jupyter/jupyter_lab_config.py

ARG JUPYTER_PASSWORD
RUN /home/${USER_NAME}/.venv/${VIRTUAL_ENV}/bin/python -c \
    'from jupyter_server.auth import passwd;print(passwd("'"${JUPYTER_PASSWORD}"'"))' | \
    awk '{print "c.ServerApp.password = \""$1"\""}' >> ~/.jupyter/jupyter_lab_config.py



USER root

RUN service xrdp stop && service ssh stop

RUN echo root:rootpass | chpasswd
EXPOSE 22
EXPOSE 3389
EXPOSE 8888
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# CMD ["/usr/bin/supervisord"]
COPY ./entrypoint.sh /usr/local/entrypoint.sh
ENTRYPOINT [ "bash", "/usr/local/entrypoint.sh" ]
