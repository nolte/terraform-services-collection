

variable "buckets_source_access_key" {
  default = ""
}
variable "buckets_source_secret_key" {
  default = ""
}
variable "buckets_source_endpoint" {
  default = ""
}

variable "buckets_target_access_key" {
  default = "AKIAIOSFODNN7EXAMPLE"
}
variable "buckets_target_secret_key" {
  default = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}
variable "buckets_target_endpoint" {
  default = "http://minio.minio.svc:9000"
}


resource "k8sraw_yaml" "migrate_buckets_secret" {
  yaml_body = <<YAML
---
apiVersion: v1
kind: Secret
metadata:
  name: s3-rclone
type: Opaque
stringData:
  rclone-online.conf: |-
    [minio]
    type = s3
    env_auth = false
    access_key_id = ${var.buckets_source_access_key}
    secret_access_key = ${var.buckets_source_secret_key}
    region = us-east-1
    endpoint = ${var.buckets_source_endpoint}
    location_constraint =
    server_side_encryption =
  rclone-local.conf: |-
    [minio]
    type = s3
    env_auth = false
    access_key_id = ${var.buckets_target_access_key}
    secret_access_key = ${var.buckets_target_secret_key}
    region = us-east-1
    endpoint = ${var.buckets_target_endpoint}
    location_constraint =
    server_side_encryption =
  YAML
}

resource "k8sraw_yaml" "migrate_buckets_tekton_task" {
  depends_on = [k8sraw_yaml.migrate_buckets_secret]
  yaml_body  = <<YAML
---
apiVersion: tekton.dev/v1alpha1
kind: Task
metadata:
  name: rclone-copy
spec:
  inputs:
    params:
      - name: configSecretName
        type: string
      - name: sourceConfigName
        type: string
      - name: targetConfigName
        type: string        
      - name: bucket
        type: string                 
  steps:
    - name: download
      image: rclone/rclone:latest
      command: ["rclone"]
      args: ["sync","minio:$(inputs.params.bucket)","/data","--config","/var/run/rclone/$(inputs.params.sourceConfigName)"]
      volumeMounts:
      - name: rclone-config
        mountPath: "/var/run/rclone/"
        readOnly: true  
      - name: bucket-data
        mountPath: "/data"
    - name: create-dest-bucket
      image: rclone/rclone:latest
      command: ["rclone"]
      args: ["mkdir","minio:$(inputs.params.bucket)","--config","/var/run/rclone/$(inputs.params.targetConfigName)"]
      volumeMounts:
      - name: rclone-config
        mountPath: "/var/run/rclone/"
        readOnly: true
    - name: upload
      image: rclone/rclone:latest
      command: ["rclone"]
      args: ["sync","/data","minio:$(inputs.params.bucket)","--config","/var/run/rclone/$(inputs.params.targetConfigName)"]
      volumeMounts:
      - name: rclone-config
        mountPath: "/var/run/rclone/"
        readOnly: true  
      - name: bucket-data
        mountPath: "/data"              
  volumes:
  - name: bucket-data
    emptyDir: {}
  - name: rclone-config
    secret:
      secretName: "$(inputs.params.configSecretName)"
  YAML
}


resource "k8sraw_yaml" "migrate_buckets_tekton_pipeline" {
  depends_on = [k8sraw_yaml.migrate_buckets_tekton_task]
  yaml_body  = <<YAML
---
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: clone-buckets
spec:       
  tasks:
    - name: backup-copy
      taskRef:
        name: rclone-copy
      params:
      - name: configSecretName
        value: s3-rclone
      - name: sourceConfigName
        value: rclone-online.conf
      - name: targetConfigName
        value: rclone-local.conf 
      - name: bucket
        value: backup
    - name: terraform-states-copy
      taskRef:
        name: rclone-copy
      params:
      - name: configSecretName
        value: s3-rclone
      - name: sourceConfigName
        value: rclone-online.conf
      - name: targetConfigName
        value: rclone-local.conf 
      - name: bucket
        value: terraform-states
    - name: helm-charts-copy
      taskRef:
        name: rclone-copy
      params:
      - name: configSecretName
        value: s3-rclone
      - name: sourceConfigName
        value: rclone-online.conf
      - name: targetConfigName
        value: rclone-local.conf 
      - name: bucket
        value: helm-charts  
  YAML
}


resource "k8sraw_yaml" "migrate_buckets_tekton_pipeline_run" {
  depends_on = [k8sraw_yaml.migrate_buckets_tekton_pipeline]
  yaml_body  = <<YAML
apiVersion: tekton.dev/v1alpha1
kind: PipelineRun
metadata:
  name: clone-buckets
spec:
  pipelineRef:
    name: clone-buckets  
  YAML
}
