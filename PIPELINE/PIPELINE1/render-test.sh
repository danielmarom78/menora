#!/bin/bash
for file in ./render*.yaml; do     oc apply -f "$file"; done

curl -X POST http://el-event-listener-hiv1bg-pipeline.apps.cluster-2mbd4.dynamic.redhatworkshops.io \
     -H 'Content-Type: application/json' \
     -d '{"proj": "proj2", "app": "app3"}'