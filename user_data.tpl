#cloud-config
runcmd:
# Taken from https://oracle-base.com/articles/linux/docker-install-docker-on-oracle-linux-ol8
-   dnf install -y dnf-utils zip unzip
-   dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
-   dnf remove -y runc
-   dnf install -y docker-ce --nobest
-   systemctl enable docker.service
-   systemctl start docker.service
-   sudo docker run -d -p 8080:8080 -h app_layer --name 