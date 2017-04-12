#
#Dockerfile for creating image with yardstick and its dependency
#packages installed.
#kvmfornfv1 image has all dependency packages installed.
#
FROM kvmfornfv1:latest
RUN cd /root && git clone https://gerrit.opnfv.org/gerrit/p/yardstick.git -b stable/danube
RUN cd /root/yardstick && git fetch https://gerrit.opnfv.org/gerrit/yardstick refs/changes/07/33407/2 && git checkout FETCH_HEAD
RUN sed -i -e "s/3600/9000/g" /root/yardstick/yardstick/ssh.py
RUN cd /root/yardstick && python setup.py install
WORKDIR /root
