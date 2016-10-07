#
#Dockerfile for creating image with yardstick and its dependency
#packages installed.
#kvmfornfv1 image has all dependency packages installed.
#
FROM kvmfornfv1:latest
RUN cd /root && git clone https://gerrit.opnfv.org/gerrit/p/yardstick.git -b stable/colorado
RUN var=`grep "loops" /root/yardstick/samples/cyclictest-node-context.yaml |awk '{ print $2/1000 }'`; sed -i -e "s/3600/$((var+1500))/g" /root/yardstick/yardstick/ssh.py
RUN cd /root/yardstick && python setup.py install
WORKDIR /root
