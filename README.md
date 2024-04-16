# Kubesort Script Documentation

## Description
The Kubesort script is a bash script designed to list specific resource types using the Kubernetes `kubectl` command. It provides options to sort and filter the output based on various fields.

## Requirements
- Bash shell
- `kubectl` command-line tool installed and configured
- Access to a Kubernetes cluster

## Usage
```bash
kubesort kubectl get OPTION1 OPTION2 OPTION3 [OPTION4]
Available Options
OPTION1: Specifies the resource type to list. Available options are:

pod, pods, po (Pods)
deployments, deployment, deploy (Deployments)
svc, service, services (Services)
OPTION2: Specifies the fields to display for the selected resource type. Available fields depend on the resource type selected. Common fields include:

For Pods: name, status, restarts, age, ip, node
For Deployments: name, uptodate, available, age, containers, images
For Services: name, type, clusterIP, port, age
OPTION3: Specifies the namespace to list resources from. Use all to list resources from all namespaces.

OPTION4 (optional):

--sort-by=[field]: Sorts the output by the specified field.
--filter=[field=value]: Filters the output based on the specified field and value.
# List all Pods sorted by age
kubesort kubectl get pods age all

# List Deployments sorted by available replicas in the namespace "default"
kubesort kubectl get deployments available default --sort-by=available

# List Services with a specific label selector
kubesort kubectl get services name default --filter="app=myapp"

#Notes
Ensure that kubectl is installed and configured properly.
Provide the correct resource type and fields for accurate output.
Use caution when filtering output to avoid unintended results.
