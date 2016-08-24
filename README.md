# foxpass-openvpn

Create a VPN using foxpass.com for LDAP auth

## Required Variables
* BIND_PASSWORD -- your Foxpass binder password
* CA_PEM -- CA cert (can also be mounted to /etc/openvpn/ca.pem)
* DOMAIN -- your subdomain. e.g. "lendup"
* DH_PEM -- DH cert (can also be mounted to /etc/openvpn/dh.pem)
* MGMTPASS -- openvpn management password (can also be mounted to /etc/openvpn/mgmtpass)
* SERVER_KEY -- your private key (can also be mounted to /etc/openvpn/server.key)
* SERVER_PEM -- your public cert (can also be mounted to /etc/openvpn/server.pem)

## Optional Variables
* BINDER_NAME -- Foxpass binder name
* DNS_1 -- primary DNS when PUSH_DNS is true (defaults to 208.67.222.222)
* DNS_2 -- secondary DNS when PUSH_DNS is true (defaults to 208.67.220.220)
* GROUP_FILTER -- restrict VPN access to an LDAP group
* PROTO -- udp/tcp for VPN (defaults to "tcp")
* PUSH_DNS -- should be we push DNS servers to clients? (defaults to true)
* ROUTE_ALL_TRAFFIC -- should we route all traffic? (defaults to true)
* ROUTE_SUBNET -- if not routing all traffic, what should we route (this must be set if ROUTE_ALL_TRAFFIC is not true)
* TLD -- top-level domain (defaults to "com")
* VPN_NET -- the VPN subnet (defaults to 10.10.250.0, this should not overlap with ROUTE_SUBNET)

## Examples

These examples assume that all files described above that can be host-mounted are host-mounted or added with a derivative Dockerfile.

### Route all traffic
```
docker run -d \
   -e BIND_PASSWORD="foobar" \
   -e DOMAIN="mydomain" \
   -p 1194:1194 \
   --cap-add NET_ADMIN \
   --device /dev/net/tun \
   avinson/foxpass-openvpn
```

### Route only the subnet 10.128.0.0/16 through the VPN. Restrict to the "engineer" group.
```
docker run -d \
   -e BIND_PASSWORD="foobar" \
   -e DOMAIN="mydomain" \
   -e GROUP_FILTER="engineer" \
   -e PUSH_DNS="false" \
   -e ROUTE_ALL_TRAFFIC="false" \
   -e ROUTE_SUBNET="10.128.0.0 255.255.0.0" \
   -p 1194:1194 \
   --cap-add NET_ADMIN \
   --device /dev/net/tun \
   avinson/foxpass-openvpn
```
