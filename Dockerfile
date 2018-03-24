FROM ubuntu:trusty

# override to udp at runtime if desired
ENV PROTO tcp
EXPOSE 1194/udp 1194/tcp

ENV CONSUL_TEMPLATE_VERSION 0.15.0
ENV CONSUL_TEMPLATE_URL https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip

ENV DNS_1 208.67.222.222
ENV DNS_2 208.67.220.220
ENV PUSH_DNS true
ENV ROUTE_ALL_TRAFFIC true

ENV ROUTE_SUBNET "10.10.0.0 255.255.0.0"
ENV VPN_NET "10.10.250.0"

ENV BINDER_NAME openvpn
ENV TLD com
# require these to set by the user or error out
# since nothing will work otherwise
#ENV DOMAIN mydomain
#ENV BIND_PASSWORD mydomain

RUN apt-get -qy update && apt-get -qy install software-properties-common
RUN add-apt-repository ppa:foxpass/openvpn-auth-ldap
RUN apt-get -qy update && apt-get -qy install curl iptables openvpn openvpn-auth-ldap unzip
RUN curl -o /tmp/consul-template.zip -L $CONSUL_TEMPLATE_URL && ( cd /usr/bin && unzip /tmp/consul-template.zip )

ADD etc/openvpn/ /etc/openvpn/
ADD docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

WORKDIR /etc/openvpn
ENTRYPOINT docker-entrypoint.sh
