---
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: "gitea-cert"
  namespace: "${ namespace }"
spec:
  secretName: "gitea-cert-secret"
  dnsNames:
  - ${host}
  issuerRef:
    name: "cluster-issuer"
    kind: ClusterIssuer