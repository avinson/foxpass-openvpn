# Define a job
job "vpn" {

  datacenters = ["us-west-1"]

  type = "service"
  group "vpn" {
    count = 2

    task "vpn" {
      driver = "docker"
      config {
        image = "avinson/foxpass-openvpn"
        port_map { vpn = 1194 }
        privileged = true
      }
      env {
        BIND_PASSWORD = "REDACTED"
        DOMAIN = "mydomain"
        GROUP_FILTER = "vpn"
        MGMTPASS = "REDACTED"
        PUSH_DNS = "false"
        ROUTE_ALL_TRAFFIC = "false"
        ROUTE_SUBNET = "10.1.0.0 255.255.0.0"
        VPN_NET = "10.252.250.0"
      }
      service {
        name = "vpn"
        port = "vpn"
        tags = ["infra"]
      }
      resources {
        cpu = 100
        memory = 64
        network {
          mbits = 10
          port "vpn" {
            static = 1194
          }
        }
      }
    }
  }
}
