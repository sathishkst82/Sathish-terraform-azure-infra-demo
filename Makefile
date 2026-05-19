ENV ?= dev
ENV_DIR = environments/$(ENV)

fmt:
	terraform fmt -recursive

validate:
	cd $(ENV_DIR) && terraform init -backend=false && terraform validate

lint:
	cd $(ENV_DIR) && tflint --init && tflint

docs:
	terraform-docs markdown table --output-file README.md --output-mode inject modules/vnet
	terraform-docs markdown table --output-file README.md --output-mode inject modules/vm
	terraform-docs markdown table --output-file README.md --output-mode inject modules/storage
	terraform-docs markdown table --output-file README.md --output-mode inject modules/governance

plan:
	cd $(ENV_DIR) && terraform init && terraform plan -out=tfplan

apply:
	cd $(ENV_DIR) && terraform apply tfplan
