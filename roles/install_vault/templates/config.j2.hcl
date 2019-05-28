ui = true
api_addr = "http://{{ ansible_default_ipv4.address }}:8200"

storage "consul" {
  address = "{{ ansible_default_ipv4.address }}:8500"
  path    = "vault/"
  scheme = "http"
}

listener "tcp" {
  address     = "{{ ansible_default_ipv4.address }}:8200"
  tls_disable = 1
}