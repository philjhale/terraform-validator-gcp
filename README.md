# terraform-validator-gcp

Playground for [terraform-validator](https://github.com/GoogleCloudPlatform/terraform-validator).

## Local setup

Prerequisites
- Terraform
- GCP project
- GCP credentials (./credentials.json)
- Google Cloud SDK

Set up repositories. 

In order to submit builds to Cloud Build the folder structure must be:
- Parent folder
  - terraform-validator-gcp repository
  - terraform-validator-policy-library repository
```
mdir terraform-validator-poc
cd terraform-validator-poc
git clone https://github.com/philjhale/terraform-validator-gcp.git
git clone https://github.com/philjhale/terraform-validator-policy-library.git
```

Set up environment variables.
```
export GOOGLE_PROJECT_ID=my-project-id
export TF_VAR_google_project_id=my-project-id
export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/credentials.json
# Points to clone of https://github.com/forseti-security/policy-library
export POLICY_PATH=$(pwd)/../terraform-validator-policy-library
```

Init terraform, generate plan and validate.
```
terraform init -backend-config=bucket=${GOOGLE_PROJECT_ID}_terraform
terraform plan --out=terraform.tfplan
terraform show -json ./terraform.tfplan > ./terraform.tfplan.json

docker run -it -v `pwd`:/work -v $POLICY_PATH:/policy-repo --env TEST_PROJECT=${GOOGLE_PROJECT_ID} --env GOOGLE_APPLICATION_CREDENTIALS=/work/credentials.json terraform-validator validate --policy-path=/policy-repo/ /work/terraform.tfplan.json
```

Debugging and errors.
```
# You may get an error saying the resource manager API isn't enable. If so, enable it
gcloud services enable cloudresourcemanager.googleapis.com 

# Useful it you want to poke around the container
docker run -it -v `pwd`:/terraform-validator -v $POLICY_PATH:/policy-repo -v ${GOOGLE_APPLICATION_CREDENTIALS}:/terraform-validator/credentials.json --entrypoint=/bin/bash --env TEST_PROJECT=${PROJECT_ID} --env TEST_CREDENTIALS=./credentials.json terraform-validator
```

## Cloud Build setup

Build the [terraform validator Docker image](https://github.com/GoogleCloudPlatform/terraform-validator#integration).
```
git clone https://github.com/GoogleCloudPlatform/terraform-validator
cd terraform-validator
make build-docker
```

Push to to Google Container Repository.
```
docker tag terraform-validator gcr.io/$GOOGLE_PROJECT_ID/terraform-validator
docker push gcr.io/$GOOGLE_PROJECT_ID/terraform-validator
```

Run Cloud Build. Must be run from the `terraform-validator-poc` directory.
```
gcloud builds submit . --config=terraform-validator-gcp/cloudbuild.yaml
```

# Links
- [Terraform validator repo](https://github.com/GoogleCloudPlatform/terraform-validator)
- [How to use Terraform Validator](https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md#how-to-use-terraform-validator)
- Google blog series
    - [Protecting your GCP infrastructure at scale with Forseti Config Validator](https://cloud.google.com/blog/products/identity-security/protecting-your-gcp-infrastructure-at-scale-with-forseti-config-validator)
    - [Protecting your GCP infrastructure at scale with Forseti Config Validator part two: Scanning for labels](https://cloud.google.com/blog/products/identity-security/protecting-your-gcp-infrastructure-at-scale-with-forseti-config-validator-part-two-scanning-for-labels)
    - [Protecting your GCP infrastructure at scale with Forseti Config Validator part three: Writing your own policy](https://cloud.google.com/blog/products/identity-security/protecting-your-gcp-infrastructure-with-forseti-config-validator-part-three-writing-your-own-policy)