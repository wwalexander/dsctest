dsctest
=======

Deployment
----------

`deploy.sh` starts minikube if it is not already running, builds the Docker
image for the fizzbuzz server into minikube, and applies the Kubernetes
configuration file for the cluster. The server can be accessed via a NodePort at
$(minikube ip):30000`:

    curl -X POST -H 'Content-Type: application/json' $(minikube ip):30000/fizzbuzz

Design decisions
----------------

### Docker

The Dockerfile is based on golang:1-alpine. I chose to only set the major Go
version, as Go is meant to be backwards compatible between minor releases, so
the image will get the latest improvements and bug fixes without breaking the
server code. I chose Alpine Linux as Docker recommends it for the smallest image
sizes, and chose not to specify a version as the server doesn't depend on any
specific Linux features. This image is built targeting minikube, and accessed
from Kubernetes as a local image.

### Kubernetes

The Kubernetes cluster is composed of three Kubernetes objects. `nodeport.yaml`
defines a Service of type NodePort. Since Michael specified that this project
only needs a single replica, and since it is running on minikube instead of a
real cloud host, I did not use a LoadBalancer. If we had a cloud host providing
an external IP, or if the cluster had multiple replicas of the fizzbuzz pod, I
would use a LoadBalancer instead of a NodePort. While Michael said that the
server does not need to be accessible from outside the cluster for this project,
the NodePort makes connecting with the server more predictable and
straightforward when testing the responses.

`service.yaml` defines a headless Service. Without this headless Service, the
server container will fail to start listening with a "too many colons in
address" error from Golang.

`deployment.yaml` defines a single-replica Deployment, which will recreate the
pod if it goes down for high availability. This deployment specifies a pod
template that uses the local Docker image on the minikube VM, via
`imagePullPolicy: Never`. In real-world usage, I would push images to a private
or public Docker registry to streamline deployment. Additionally, if it was
required for the cluster to have multiple replicas, I would pull the counter
state out of the fizzbuzz server and store it in a PersistentVolume, using a
StatefulSet instead of a Deployment.
