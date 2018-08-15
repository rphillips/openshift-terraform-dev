.PHONY: clean destroy install

clean:
	rm -f terraform.tfstate*

destroy:
	terraform destroy -force

install:
	terraform apply -auto-approve -var-file=constants.tfvar
