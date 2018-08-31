FROM ubuntu
MAINTAINER Euan Ong (euan.l.y.ong@gmail.com)

RUN apt-get -y update

#Install LAMP
RUN apt-get -y install apache2
RUN apt-get -y install php
RUN apt-get -y install libapache2-mod-php7.0
RUN service apache2 restart

#Install git
RUN apt-get -y install git

#Add ssh keys
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts
RUN mkdir /root/tempssh
ADD ./ssh/. /root/tempssh
RUN mv /root/tempssh/* /root/.ssh/
RUN chmod 600 /root/.ssh/id_rsa

#Add musicblocks-cordova repo
WORKDIR /var/www
RUN git clone git@github.com:eohomegrownapps/musicblocks-cordova.git

#Add android stuff
RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:ubuntu-desktop/ubuntu-make
RUN apt-get -y update
RUN apt-get -y install ubuntu-make
RUN umake android android-sdk --accept-license /root/.local/share/umake/android/android-sdk
ENV ANDROID_HOME /root/.local/share/umake/android/android-sdk
ENV PATH ${PATH}:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
RUN yes | /root/.local/share/umake/android/android-sdk/tools/bin/sdkmanager "build-tools;26.0.1"
RUN yes | /root/.local/share/umake/android/android-sdk/tools/bin/sdkmanager "extras;android;m2repository"
RUN yes | /root/.local/share/umake/android/android-sdk/tools/bin/sdkmanager "platforms;android-16"

#Install cordova
RUN apt-get -y install nodejs npm
RUN ln -s `which nodejs` /usr/bin/node
RUN npm install -g cordova

#Install gradle
RUN apt-get -y install gradle

#Configure cordova for musicblocks
WORKDIR /var/www/musicblocks-cordova
RUN cordova prepare

#Add scripts
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install lockfile-progs procmail
COPY script.sh /root/
RUN chmod +x /root/script.sh
RUN apt-get -y install sudo
RUN echo "www-data ALL = NOPASSWD: /root/script.sh">>/etc/sudoers
RUN echo 'Defaults  env_keep += "ANDROID_HOME"'>>/etc/sudoers
RUN rm /var/www/html/index.html
COPY index.php /var/www/html/
EXPOSE 22 80
RUN chmod g+w /var/log/apache2/error.log
RUN chgrp www-data /var/log/apache2/error.log
RUN git config --global user.email "euan.l.y.ong@gmail.com" && git config --global user.name "Euan Ong"
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && ln -sf /proc/self/fd/1 /var/log/apache2/error.log
CMD ["/usr/sbin/apachectl","-DFOREGROUND"]