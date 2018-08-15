.PHONY: clean destroy install validate

all:
	@echo Run make install

clean:
	rm -f terraform.tfstate*

destroy:
	terraform destroy -force

cleanup: destroy clean

install:
	terraform init
	terraform apply -auto-approve -var-file=constants.tfvar

validate:
	terraform validate -var-file=constants.tfvar
