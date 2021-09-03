FROM ubuntu:20.04

# System Setup ================================================================
RUN sed -i -e 's/http:\/\/archive.ubuntu/http:\/\/jp.archive.ubuntu/g' /etc/apt/sources.list
RUN apt update -y && apt upgrade -y && rm -rf /var/lib/apt/lists/*
# Basic
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update -y && apt install -y \
        sudo apt-utils net-tools\
        wget curl git \
        gcc g++ gfortran golang make \
        vim \
        supervisor openssh-server \
        xrdp lxqt-core \
        ibus-mozc language-pack-ja \
    && \
    unset DEBIAN_FRONTEND && \
    rm -rf /var/lib/apt/lists/*

# Node
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt install -y nodejs
# Python
ARG PYTHON_VERSION=3.9
RUN apt install -y python3 python3-pip python3-venv
RUN apt install -y python${PYTHON_VERSION} \
                   python${PYTHON_VERSION}-dev \
                   python${PYTHON_VERSION}-venv

RUN sed -i -e 's/http:\/\/jp.archive.ubuntu/http:\/\/archive.ubuntu/g' /etc/apt/sources.list

# sshd serverconfig -----------------------------------------------------------
RUN mkdir /var/run/sshd && \
    sed -e 's/^new_cursors=true/new_cursors=false/g' -i /etc/xrdp/xrdp.ini && \
    sed -e 's/test -x \/etc\/X11\/Xsession/# test -x \/etc\/X11\/Xsession/g' \
        -i  /etc/xrdp/startwm.sh && \
    sed -e 's/exec \/bin\/sh \/etc\/x11\/Xsession/# exec \/bin\/sh \/etc\/x11\/Xsession/g' \
        -i /etc/xrdp/startwm.sh && \
    echo '' >> /etc/xrdp/startwm.sh && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /etc/xrdp/startwm.sh && \
    echo 'exec lxqt-session' >> /etc/xrdp/startwm.sh && \
    echo "test -x /etc/X11/Xsession && exec /etc/X11/Xsession" \
         >> /etc/xrdp/startwm.sh && \
    echo "exec /bin/sh /etc/X11/Xsession" >> /etc/xrdp/startwm.sh && \
    gpasswd -a xrdp ssl-cert


# User ========================================================================
ARG USER_NAME=developer
ARG USER_PASSWORD=developer
# user generate
RUN useradd -m ${USER_NAME} && \
    echo ${USER_NAME}:${USER_PASSWORD} | chpasswd && \
    chsh -s /bin/bash ${USER_NAME}
USER ${USER_NAME}

# gui system setting
RUN echo 'startlxqt' > /home/${USER_NAME}/.xsessionrc
RUN echo 'export GTK_IM_MODULE=ibus' >> /home/${USER_NAME}/.bashrc && \
    echo 'export XMODIFIERS=@im=ibus' >> /home/${USER_NAME}/.bashrc && \
    echo 'export QT_IM_MODULE=ibus' >> /home/${USER_NAME}/.bashrc && \
    mkdir -p /home/${USER_NAME}/.config/autostart && \
    echo '[Desktop Entry]' > /home/${USER_NAME}/.config/autostart/ibus.desktop && \
    echo 'Exec=ibus-daemon -rdx' >> /home/${USER_NAME}/.config/autostart/ibus.desktop && \
    echo 'Name=ibus' >> /home/${USER_NAME}/.config/autostart/ibus.desktop && \
    echo 'OnlyShowIn=LXQt;' >> /home/${USER_NAME}/.config/autostart/ibus.desktop && \
    echo 'Type=Application' >> /home/${USER_NAME}/.config/autostart/ibus.desktop && \
    echo 'Version=1.0' >> /home/${USER_NAME}/.config/autostart/ibus.desktop & \
    im-config -n ibus

# python
ARG VIRTUAL_ENV=py39
RUN python${PYTHON_VERSION} -m venv /home/${USER_NAME}/.venv/${VIRTUAL_ENV} && \
    echo "" >> ~/.bashrc && \
    echo source ~/.venv/${VIRTUAL_ENV}/bin/activate >> ~/.bashrc
RUN /home/${USER_NAME}/.venv/${VIRTUAL_ENV}/bin/python -m pip install --upgrade pip wheel setuptools && \
    /home/${USER_NAME}/.venv/${VIRTUAL_ENV}/bin/python -m pip install jupyter jupyterlab \
    autopep8 yapf pylint rope jedi flake8 \
    numpy pandas scipy scikit-learn statsmodels sympy \
    matplotlib seaborn \
    openpyxl xlrd \
    sphinx sphinx_rtd_theme \
    sqlalchemy \
    pytest pytest-html pytest-cov \
    tensorflow qiskit
RUN /home/${USER_NAME}/.venv/${VIRTUAL_ENV}/bin/python -m pip install tensorflow

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
CMD ["/usr/bin/supervisord"]
