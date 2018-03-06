#!/usr/bin/env bash


set -e            # fail fast
set -u            # fail when variable is unbound
set -o pipefail   # don't ignore exit codes when piping output
set -x            # enable debugging


# Have to enable the VMSS Health Probe feature to enable Rolling VMSS updates!
# @see https://github.com/Azure/vm-scale-sets/blob/master/preview/upgrade/readme.md
# Register-AzureRmProviderFeature -FeatureName AllowVmssHealthProbe -ProviderNamespace Microsoft.Network
# az feature register --name AllowVmssHealthProbe \
#                     --namespace Microsoft.Network
# az provider register -n Microsoft.Network

##

NAMESPACE=$1
RESOURCE_GROUP=${NAMESPACE}-rg
SERVICE_PLAN=${NAMESPACE}-sp
APP_NAME=${NAMESPACE}-app
KEY_VAULT=${NAMESPACE}-kv
STORAGE_ACCOUNT=${NAMESPACE}sa
AZ_LOCATION="West Europe"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ENVIRONMENT=Production

# This env var needs to be set in order to setup the VSTS Agent on the VM
VSTS_PAT=${VSTS_PAT:-NOT SET}

# Set az cli defaults
az configure --defaults \
    location="${AZ_LOCATION}" \
    group=${RESOURCE_GROUP} \
    web=${APP_NAME} \
    vmss=${NAMESPACE}-web

# Create Resource Group
az group create --verbose --name ${RESOURCE_GROUP}

# Create Service Plan
az group deployment create --verbose \
    --name ${NAMESPACE}-deployment-sp \
    --template-file appserviceplan.json \
    --parameters \
        namespace=${NAMESPACE} \
        environment=${ENVIRONMENT} \
        appName=web1 \
        skuPricingTierSize=S1 \
        buildDate=${BUILD_DATE} \
        buildBy=$(whoami)

