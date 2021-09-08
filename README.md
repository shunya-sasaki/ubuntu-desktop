# ubuntu-desktop

This is the docker container project of my desktop environment for program development.

The container is based ubuntu, and LXQt is used for desktop environment.

## Usage

### Deployment

```
docker run  shunyasasaki/ubuntu-desktop -p <your ssh port>:22 -p <your rdp port> -v <your ssh pub key path> /home/developer/.ssh/authorized_keys
```


## Installed Softwares

<details><summary>apt packages</summary>

* base system tools
    * sudo
    * apt-utils
    * net-tools
    * wget
    * curl
    * git
    * supervisor

* desktop environment
    * lxqt-core
    * xrdp
    * ibus-mozc
    * language-pack-ja

* program languages (compilers & interpreters)
    * gcc
    * g++
    * gfortran
    * python3.9
    * golang
    * nodejs

* text editor
    * vim

</details>

<details><summary>python libralies</summary>

* jupyter, jupyterlab
* autopep8, yapf, flake8
* numpy, pandas, scipy, sympy, statsmodels, scikit-learn
* matplotlib, seaborn
* openpyxl, xlrd
* sphinx, sphinx_rtd_theme
* sqlalchemy
* pytest, pytest-html, pytest-cov
* tensorflow
* qiskit

</summary>