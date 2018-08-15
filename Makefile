.PHONY: clean destroy install validate

clean:
	rm -f terraform.tfstate*

destroy:
	terraform destroy -force

install:
	terraform apply -auto-approve -var-file=constants.tfvar

validate:
	terraform validate
