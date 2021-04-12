#!/bin/bash
aws s3 cp s3://twente-dask-emr-hello-world/bootstrap/environment.tar.gz /home/hadoop

echo "Installing Miniconda"
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh
bash /tmp/miniconda.sh -b -p $HOME/miniconda
rm /tmp/miniconda.sh

conda install -c conda-forge -y -q \
  conda-pack \
  notebook ipywidgets jupyter-server-proxy

echo -e '\nexport PATH=$HOME/miniconda/bin:$PATH' >> $HOME/.bashrc
source $HOME/.bashrc
conda update conda -y
mkdir -p my_env
tar -xzf environment.tar.gz -C my_env
source my_env/bin/activate
conda-unpack

# Check if running on the master node. If not, there's nothing do.
grep -q '"isMaster": true' /mnt/var/lib/info/instance.json \
|| { echo "Not running on master node, nothing to do" && exit 0; }

echo "Configuring Dask"
mkdir -p $HOME/.config/dask
cat <<EOT >> $HOME/.config/dask/config.yaml
distributed:
  dashboard:
    link: "/proxy/{port}/status"

yarn:
  environment: /home/hadoop/environment.tar.gz
  deploy-mode: local

  worker:
    env:
      ARROW_LIBHDFS_DIR: /usr/lib/hadoop/lib/native/

  client:
    env:
      ARROW_LIBHDFS_DIR: /usr/lib/hadoop/lib/native/
EOT
# Also set ARROW_LIBHDFS_DIR in ~/.bashrc so it's set for the local user
echo -e '\nexport ARROW_LIBHDFS_DIR=/usr/lib/hadoop/lib/native' >> $HOME/.bashrc

echo "Configuring Jupyter"
mkdir -p $HOME/.jupyter
JUPYTER_PASSWORD="dask-user"
HASHED_PASSWORD=`python -c "from notebook.auth import passwd; print(passwd('$JUPYTER_PASSWORD'))"`
cat <<EOF >> $HOME/.jupyter/jupyter_notebook_config.py
c.NotebookApp.password = u'$HASHED_PASSWORD'
c.NotebookApp.open_browser = False
c.NotebookApp.ip = '0.0.0.0'
EOF

echo "Configuring Jupyter Notebook Upstart Service"
cat <<EOF > /tmp/jupyter-notebook.conf
description "Jupyter Notebook Server"
start on runlevel [2345]
stop on runlevel [016]
respawn
respawn limit unlimited
exec su - hadoop -c "jupyter notebook" >> /var/log/jupyter-notebook.log 2>&1
EOF
sudo mv /tmp/jupyter-notebook.conf /etc/init/

echo "Starting Jupyter Notebook Server"
sudo initctl reload-configuration
sudo initctl start jupyter-notebook
