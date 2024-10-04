install:
	pixi install
	pixi run pre-commit install

test:
	pixi run test

python:
	pixi run python

rename-package:
	@if [ -z "$(name)" ]; then \
		echo "Error: Please provide a name argument. Usage: make rename-package name=new_package_name [current_name=old_package_name]"; \
		exit 1; \
	fi
	$(eval current_name := $(if $(current_name),$(current_name),package_name))
	@echo "Renaming package from $(current_name) to $(name)..."
	@find . -type f -not -path '*/\.*' -exec sh -c ' \
		if file -b --mime-type "{}" | grep -q "^text/"; then \
			sed -i "" "s/$(current_name)/$(name)/g" "{}"; \
		fi' \;
	@if [ -d "$(current_name)" ]; then \
		mv $(current_name) $(name); \
	else \
		echo "Warning: Directory '$(current_name)' not found. Skipping directory rename."; \
	fi
	@echo "Package renamed successfully."
