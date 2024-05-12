#!/bin/bash
podman build -t pipelineutils -f containerfile.yaml
podman tag pipelineutils quay.io/dmarom/pipelineutils:0.0.1
podman push quay.io/dmarom/pipelineutils:0.0.1