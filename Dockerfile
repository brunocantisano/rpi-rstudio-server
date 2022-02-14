FROM arturklauser/raspberrypi-rstudio-server:1.1.463-stretch

RUN groupadd rstudio-users \
    && useradd -m -d /home/myuser myuser \
    && usermod -a -G rstudio-users myuser \
    && echo 'myuser:MyUs3r' | chpasswd \
    && echo "server-user=myuser" >> /etc/rstudio/rserver.conf \
    && echo "auth-required-user-group=rstudio-users" >> /etc/rstudio/rserver.conf

VOLUME /home/myuser/R/arm-unknown-linux-gnueabihf-library/3.3

