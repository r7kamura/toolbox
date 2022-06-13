#!/bin/bash
set -eu
set -o pipefail

# Set these 2 variables.
PROJECT_ID="godolog-example-15" # e.g. godolog-example
GITHUB_REPO="r7kamura/godolog-example" # e.g. r7kamura/godolog-example

SERVICE_ACCOUNT_ID="google-drive-reader"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
POOL_NAME="${PROJECT_ID}"
PROVIDER_NAME="${PROJECT_ID}"

gcloud projects create "${PROJECT_ID}"

gcloud services enable drive.googleapis.com --project "${PROJECT_ID}"
gcloud services enable iamcredentials.googleapis.com --project "${PROJECT_ID}"

gcloud iam service-accounts create "${SERVICE_ACCOUNT_ID}" --display-name "${SERVICE_ACCOUNT_ID}" --project "${PROJECT_ID}"

echo "Wait a minute..."
sleep 60
gcloud iam workload-identity-pools create "${POOL_NAME}" --project "${PROJECT_ID}" --location="global"

WORKLOAD_IDENTITY_POOL_ID=$(gcloud iam workload-identity-pools describe "${POOL_NAME}" --project="${PROJECT_ID}" --location="global" --format="value(name)")

gcloud iam workload-identity-pools providers create-oidc "${PROVIDER_NAME}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="${POOL_NAME}" \
  --display-name="${PROVIDER_NAME}" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.actor=assertion.actor,attribute.aud=assertion.aud" \
  --issuer-uri="https://token.actions.githubusercontent.com"

gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT_EMAIL}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${GITHUB_REPO}"

echo "GOOGLE_SERVICE_ACCOUNT: ${SERVICE_ACCOUNT_EMAIL}"
echo "GOOGLE_WORKLOAD_IDENTITY_PROVIDER: ${WORKLOAD_IDENTITY_POOL_ID}/providers/${PROVIDER_NAME}"
