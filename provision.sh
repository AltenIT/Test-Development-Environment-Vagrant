#!/usr/bin/env bash
set -e
export HOME=/home/vagrant
export IDEA_IC_VERSION=ideaIC-2018.3.2
export SET_VAGRANT_AS_OWNER="sudo chown -R vagrant:vagrant /home/vagrant"
export FLYWAY_VERSION=4.2.0
export SUT_GIT_URL=https://github.com/AltenIT/springmvc-shoppingcart-sample.git
export SUT_NAME=springmvc-shoppingcart-sample

echo  provisioning the Virtual machine

echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/webupd8team-java.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | sudo tee -a /etc/apt/sources.list.d/webupd8team-java.list
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
sudo apt-get update
sudo apt-get install -y build-essential
sudo apt-get install -y libmysqlclient-dev
sudo apt-get install -y git
sudo apt-get install -y firefox-esr #browsers #sudo apt-get install -y google-chrome-stable
sudo apt-get install -y oracle-java8-installer
sudo apt-get install -y oracle-java8-set-default
sudo apt-get install -y maven

#mysql password
debconf-set-selections <<< 'mysql-server mysql-server/root_password password vagrant'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password vagrant'
sudo apt-get install -y --force-yes mysql-server
sudo dpkg --configure -a

if [[ ! -d ./springmvc-shoppingcart-sample ]]; then
    echo  springmvc-shoppingcart-sample directory does not exist create it.
    git clone $SUT_GIT_URL
else
    cd springmvc-shoppingcart-sample
    git pull
    cd $HOME
fi

$SET_VAGRANT_AS_OWNER

cd $HOME
# springmvc-shoppingcart-sample code
if [[ ! -d ./springmvc-shoppingcart-sample ]]; then
    git clone $SUT_GIT_URL
fi

cd springmvc-shoppingcart-sample
git pull

cd $HOME && $SET_VAGRANT_AS_OWNER


# Mysql Local database
echo Create a local Database
mysql --user=root --password=vagrant --execute="DROP DATABASE if exists blog; CREATE DATABASE blog CHARACTER SET utf8;"
mysql --user=root --password=vagrant --execute="GRANT USAGE ON *.* TO 'bloguser'@'localhost';DROP USER 'bloguser'@'localhost';"
mysql --user=root --password=vagrant --execute="CREATE USER 'bloguser'@'localhost' IDENTIFIED BY 'blogpassword';"
mysql --user=root --password=vagrant --execute="GRANT ALL PRIVILEGES ON blog.* TO 'bloguser'@'localhost' WITH GRANT OPTION;"

cd $HOME && cd springmvc-shoppingcart-sample

# Ide
cd ~/Downloads/ 
if [[ ! -d ./$IDEA_IC_VERSION ]]; then
    wget -q https://download.jetbrains.com/idea/$IDEA_IC_VERSION.tar.gz
    mkdir $IDEA_IC_VERSION
    tar xzf $IDEA_IC_VERSION.tar.gz --strip-components 1 -C ./$IDEA_IC_VERSION/
    echo -e "[Desktop Entry]\n" \
    "Name=Idea\n" \
    "GenericName=IntelliJ Idea\n" \
    "Comment=Edit text files\n" \
    "Exec=/home/vagrant/Downloads/$IDEA_IC_VERSION/bin/idea.sh %F\n" \
    "Terminal=false\n" \
    "Type=Application\n" \
    "Icon=/home/vagrant/Downloads/$IDEA_IC_VERSION/bin/idea.png\n" \
    "Categories=Programming;IDE;\n" \
    "StartupNotify=true" > ~/Desktop/Idea.desktop
fi

cd $HOME && $SET_VAGRANT_AS_OWNER

cd $HOME && cd springmvc-shoppingcart-sample/shoppingcart
mvn clean install

echo -e "#!/bin/sh\n" \
"cd /home/vagrant/springmvc-shoppingcart-sample/shoppingcart\n" \
"mvn clean jetty:run" > ~/Start-springmvc-shoppingcart-sample.sh

chmod +x ~/Start-springmvc-shoppingcart-sample.sh


echo -e "[Desktop Entry]\n" \
    "Name=Run springmvc-shoppingcart-sample\n" \
    "GenericName=springmvc-shoppingcart-sample\n" \
    "Exec=/home/vagrant/Start-springmvc-shoppingcart-sample.sh %F\n" \
    "Terminal=true\n" \
    "Type=Application\n" \
    "Icon=" \
    "Categories=" \
    "StartupNotify=false" > ~/Desktop/Start-springmvc-shoppingcart-sample.desktop

chmod +x ~/Desktop/Start-springmvc-shoppingcart-sample.desktop

cp -r /root/.m2 /home/vagrant

chown -R vagrant:vagrant /home/vagrant



