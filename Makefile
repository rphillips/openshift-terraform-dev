.PHONY: clean destroy install validate

all:
	@echo Run make install

_destroy:
	terraform destroy -force
	rm -f terraform.tfstate*

clean: _destroy

install:
	terraform init
	terraform apply -auto-approve -var-file=constants.tfvar

validate:
	terraform validate -var-file=constants.tfvar
