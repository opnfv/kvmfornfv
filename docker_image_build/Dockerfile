#
#Dockerfile for creating image with yardstick and its dependency
#packages installed.
#kvmfornfv1 image has all dependency packages installed.
#
FROM kvmfornfv1:latest
RUN cd /root && git clone https://gerrit.opnfv.org/gerrit/p/yardstick.git -b stable/danube
RUN apt-get install -y python-pip
RUN pip install influxdb django
RUN sed -i -e "s/3600/9000/g" /root/yardstick/yardstick/ssh.py
RUN cd /root/yardstick && python setup.py install
WORKDIR /root
