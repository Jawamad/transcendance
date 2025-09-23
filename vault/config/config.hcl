listener "tcp" {
  address     = "0.0.0.0:18222"
  tls_disable = 1
}

api_addr = "http://0.0.0.0:18222"
