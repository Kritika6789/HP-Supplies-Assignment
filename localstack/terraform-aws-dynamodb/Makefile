# (C) Copyright 2019-2022 HP Development Company, L.P.
# Confidential computer software. Valid license from HP required for possession, use or copying.
# Consistent with FAR 12.211 and 12.212, Commercial Computer Software,
# Computer Software Documentation, and Technical Data for Commercial Items are licensed
# to the U.S. Government under vendor's standard commercial license.
#

.DEFAULT: default
.SILENT: update-docs format validate test
.PHONY: update-docs format validate test

default: update-docs format validate

update-docs:
	echo "Updating repository documentation..."
	for mod in `ls -d modules/*/`; do \
		echo "Running terraform-docs on $$mod\n"; \
		terraform-docs $$mod -c resources/terraform-docs/config.yaml; \
	done

format:
	echo "Formatting .tf files..."
	terraform fmt --recursive

validate:
	echo "Validating all terraform modules and examples..."
	for ex in `ls -d examples/*/`; do \
		cd $$ex; \
		echo "Running terraform validate on $$ex:\n"; \
		terraform init -backend=false; \
		terraform validate; \
		cd -; \
	done

test:
ifndef GOPRIVATE
	$(error GOPRIVATE envvar is undefined, export GOPRIVATE=github.azc.ext.hp.com)
endif

	if git config --get url.git@github.azc.ext.hp.com:.insteadof; then \
		echo "Git config settings found..."; \
	else \
		echo "Git config settings NOT found, run the following command:"; \
		echo 'git config --global url."git@github.azc.ext.hp.com:".insteadOf "https://github.azc.ext.hp.com"'; \
	fi

	echo "Running integration tests..."

ifndef name
	cd test; \
	go test -v -timeout 60m; \
	cd -
endif

ifdef name
	cd test; \
	go test -v -timeout 60m -run TestTerraformModules//$(name); \
	cd -
endif
