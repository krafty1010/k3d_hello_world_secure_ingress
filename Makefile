SHELL := /bin/bash -o pipefail
KUBECTL := kubectl --context k3d-cluster

.PHONY: create-k3d-cluster
.PHONY: delete-k3d-cluster

create-k3d-cluster: delete-k3d-cluster
	@which k3d >> /dev/null || echo "k3d must be installed to create local Kubernetes cluster\n==> visit https://k3d.io/ \n\n wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash" \
	&& k3d cluster create cluster --api-port 6550 -p "8080:80@loadbalancer" --agents 2

delete-k3d-cluster:
	@echo "Deleting existing Kubernetes cluster..." && k3d cluster delete cluster

build-myapp:
	docker build -t myapp:1.1 ./myapp

deploy: build-myapp create-k3d-cluster
	k3d image import myapp:1.1 --cluster cluster \
	&& ${KUBECTL} apply -f ./manifests \
	&& echo "Kubernetes cluster available on Kubernetes context k3d-cluster"