#!/usr/bin/env bash


set -e            # fail fast
set -u            # fail when variable is unbound
set -o pipefail   # don't ignore exit codes when piping output
set -x            # enable debugging

##

# The demo namespace. MUST be globally unique!
NAMESPACE=${1:-dx99}
RESOURCE_GROUP=${NAMESPACE}-rg
SERVICE_PLAN=${NAMESPACE}-sp
APP_NAME=web1
FULL_APP_NAME=${NAMESPACE}-${APP_NAME}
KEY_VAULT=${NAMESPACE}-kv
STORAGE_ACCOUNT=${NAMESPACE}sa
AZ_LOCATION="West Europe"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ENVIRONMENT=Production

# Set az cli defaults
az configure --defaults \
    location="${AZ_LOCATION}" \
    group=${RESOURCE_GROUP} 

# Create Resource Group
az group create --verbose --name ${RESOURCE_GROUP}

# Create Service Plan, Site, and PreProd slot
az group deployment create --verbose \
    --name ${NAMESPACE}-deployment-sp \
    --template-file app-service.json \
    --parameters \
        namespace=${NAMESPACE} \
        environment=${ENVIRONMENT} \
        appName=${APP_NAME} \
        skuPricingTierSize=S1 \
        buildDate=${BUILD_DATE} \
        buildBy=$(whoami)

# https://docs.microsoft.com/en-us/cli/azure/webapp/config/appsettings?view=azure-cli-latest
az webapp config appsettings set -n ${FULL_APP_NAME} \
    --settings \
        FOO=6.9.1 \
        BAR=6123

az webapp config appsettings set -n ${FULL_APP_NAME}/slots/preprod \
    --settings \
        FOO=12.3.54 \
        BAR=0000x

# Update some tags
az webapp update --verbose -n ${FULL_APP_NAME}/slots/preprod \
    --set \
        clientAffinityEnabled=false \
        tags.OWNER=iskandar \
        tags.PURPOSE=demonstration