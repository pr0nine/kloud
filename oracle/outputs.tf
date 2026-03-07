output "oke_cluster_ocid" {
  value       = oci_containerengine_cluster.k8s_cluster.id
  description = "The OCID of the OKE cluster"
}

output "cluster_endpoints" {
  value       = oci_containerengine_cluster.k8s_cluster.endpoints
  description = "Endpoints for the Kubernetes cluster"
}
