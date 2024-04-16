#!/bin/bash

# This is a bash script. This script is designed to list specific resource types using Kubernetes kubectl command and optionally sort them.

# Function to print help message
print_help_message () {
cat << EOF
   Usage: kubesort kubectl get OPTION1 OPTION2 OPTION3 [OPTION4]

   Available options are:
        OPTION1: (pod/pods/po), (deployments/deployment/deploy), (svc/service/services)

        OPTION2 (pod/pods/po):
                name, status, restarts, age, ip, node

        OPTION2 (deployments/deployment/deploy):
                name, uptodate, available, age, containers, images

        OPTION2 (svc/service/services):
                name, type, clusterIP, externalIP, ports, age

        OPTION3: namespace-name or all

        OPTION4 (optional): --sort-by=[field], --filter=[field=value]
EOF
exit
}

# Function to define options for different types
define_options () {
    local TYPE=$1
    case "$TYPE" in
        pod|pods|po)
            ARG[name]=".metadata.name"
            ARG[status]=".status.phase"
            ARG[restarts]=".status.containerStatuses[0].restartCount"
            ARG[age]=".status.startTime"
            ARG[ip]=".status.podIP"
            ARG[node]=".spec.nodeName"
            ;;
        deploy|deployments|deployment)
            ARG[name]=".metadata.name"
            ARG[uptodate]=".status.updatedReplicas"
            ARG[available]=".metadata.availableReplicas"
            ARG[age]=".metadata.creationTimestamp"
            ARG[containers]=".spec.template.spec.containers[*].name"
            ARG[images]=".spec.template.spec.containers[*].image"
            ;;
        svc|service|services)
            ARG[name]=".metadata.name"
            ARG[type]=".spec.type"
            ARG[clusterip]=".spec.clusterIP"
            ARG[port]=".spec.ports[*].port"
            ARG[age]=".metadata.creationTimestamp"
            ;;
        *)
            print_help_message
            ;;
    esac
    OPTION1="$TYPE"
    OPTION2=${ARG[$CMD]}
}

CMD=$4
OPTION3=$5
SORT_BY=""
FILTER=""
[[ -z "$CMD" ]] && CMD="help"

# Parse optional arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --sort-by)
            SORT_BY="$2"
            shift
            ;;
        --filter)
            FILTER="$2"
            shift
            ;;
        *)
            ;;
    esac
    shift
done

# Check if the kubectl command exists
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl command not found. Make sure kubectl is installed and in your PATH." >&2
    exit 1
fi

# Determine the command and define options accordingly
case "$CMD" in
    pod|pods|po)
      define_options "pod"
    ;;
    deploy|deployments|deployment)
      define_options "deployment"
    ;;
    svc|service|services)
      define_options "service"
    ;;
    *)
      print_help_message
    ;;
esac

# Set default sort field if not provided
if [[ -z "$SORT_BY" ]]; then
    SORT_BY="AGE" # Default sort field
fi

SORT_ARG="--sort-by=$SORT_BY"

if [[ -n "$FILTER" ]]; then
    FILTER_ARG="--field-selector=$FILTER"
fi

# Add all namespaces option if OPTION3 is "all"
if [[ $OPTION3 == "all" ]]; then
    OPTION3="--all-namespaces"
fi

# Run the kubectl command
kubectl get $OPTION1 $SORT_ARG $FILTER_ARG -n $OPTION3 -o wide
