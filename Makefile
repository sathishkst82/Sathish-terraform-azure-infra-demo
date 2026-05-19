fmt:
	terraform fmt -recursive

validate:
	cd environments/dev && terraform init -backend=false && terraform validate

lint:
	tflint --init && tflint --recursive

docs:
	terraform-docs markdown table --output-file README.md --output-mode inject .

plan:
	cd environments/dev && terraform init && terraform plan

apply:
	cd environments/dev && terraform init && terraform apply
