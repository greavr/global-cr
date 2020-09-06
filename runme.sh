#!/bin/bash
REGIONS=("us-central1" "us-east1" "us-east4" "europe-west1" "europe-west2" "asia-east2" "asia-northeast1" "asia-northeast2" "europe-west3" "europe-west6" "us-west3" "northamerica-northeast1" "australia-southeast1" "us-west2" "us-west4" "southamerica-east1" "asia-south1" "asia-southeast2" "asia-northeast3")

gcloud compute backend-services create cf-region-test \
    --global

for aRegion in "${REGIONS[@]}"
do
    gcloud beta compute network-endpoint-groups create cf-region-$aRegion \
    --region=$aRegion \
    --network-endpoint-type=SERVERLESS \
    --cloud-function-name=region-test-$aRegion

    gcloud beta compute backend-services add-backend cf-region-test \
        --global \
        --network-endpoint-group=cf-region-$aRegion \
        --network-endpoint-group-region=$aRegion
done