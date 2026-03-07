
.PHONY: readme
readme:
	helm-docs -c ./fastgateway -d > README.md
	helm-docs -c ./fastgateway

.PHONY: helm.create.releases
helm.create.releases:
	helm package fastgateway --destination releases
	helm repo index releases