# 1. Reserved Global Static External IP Address for the Load Balancer
resource "google_compute_global_address" "grafana_lb_ip" {
  name         = "grafana-lb-static-ip"
  project      = var.project_id
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

# 2. Google-managed SSL Certificate for Let's Encrypt / Google Trust Services
resource "google_compute_managed_ssl_certificate" "grafana_ssl_cert" {
  name    = "grafana-ssl-cert"
  project = var.project_id

  managed {
    domains = [trimsuffix(var.dns_domain_name, ".")]
  }
}

# 3. Health check for Grafana (checks HTTP on port 3000)
resource "google_compute_health_check" "grafana_health_check" {
  name    = "grafana-health-check"
  project = var.project_id

  http_health_check {
    port         = 3000
    request_path = "/api/health"
  }

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
}

# 4. Backend Service linking the Managed Instance Group to the Load Balancer
resource "google_compute_backend_service" "grafana_backend" {
  name                  = "grafana-backend-service"
  project               = var.project_id
  protocol              = "HTTP"
  port_name             = "grafana"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.grafana_health_check.id]

  backend {
    group           = google_compute_instance_group_manager.grafana_mig.instance_group
    balancing_mode  = "UTILIZATION"
    max_utilization = 0.8
    capacity_scaler = 1.0
  }
}

# 5. URL Map to route incoming secure requests to the backend service
resource "google_compute_url_map" "grafana_url_map" {
  name            = "grafana-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.grafana_backend.id
}

# 6. Target HTTPS Proxy using the managed SSL certificate
resource "google_compute_target_https_proxy" "grafana_https_proxy" {
  name             = "grafana-https-proxy"
  project          = var.project_id
  url_map          = google_compute_url_map.grafana_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.grafana_ssl_cert.id]
}

# 7. Global Forwarding Rule for HTTPS (Port 443)
resource "google_compute_global_forwarding_rule" "grafana_https_forwarding_rule" {
  name                  = "grafana-https-forwarding-rule"
  project               = var.project_id
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.grafana_https_proxy.id
  ip_address            = google_compute_global_address.grafana_lb_ip.address
}

# URL map to handle redirecting HTTP traffic to HTTPS
resource "google_compute_url_map" "grafana_http_redirect" {
  name    = "grafana-http-redirect"
  project = var.project_id

  default_url_redirect {
    https_redirect         = true
    strip_query            = false
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
  }
}

resource "google_compute_target_http_proxy" "grafana_http_redirect_proxy" {
  name    = "grafana-http-redirect-proxy"
  project = var.project_id
  url_map = google_compute_url_map.grafana_http_redirect.id
}

resource "google_compute_global_forwarding_rule" "grafana_http_forwarding_rule" {
  name                  = "grafana-http-redirect-forwarding-rule"
  project               = var.project_id
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.grafana_http_redirect_proxy.id
  ip_address            = google_compute_global_address.grafana_lb_ip.address
}

# 8. Cloud DNS Record mapping monitoring.gcp.2am.xyz to the Load Balancer IP
resource "google_dns_record_set" "grafana_dns_record" {
  name         = var.dns_domain_name
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_zone_name
  project      = var.project_id
  rrdatas      = [google_compute_global_address.grafana_lb_ip.address]
}
