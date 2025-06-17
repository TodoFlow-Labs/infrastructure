.PHONY: commit push expose-postgres expose-nats terraform-init terraform-apply terraform-destroy

commit:
	@echo "Committing changes..."
	@if [ -z "$(COMMIT_MSG)" ]; then \
		echo "❌ COMMIT_MSG is required. Usage: make commit COMMIT_MSG=\"your message\""; \
		exit 1; \
	fi

	@echo "Adding changes to git..."
	git add .

	@echo "Committing changes with message: $(COMMIT_MSG)"
	git commit -m "$(COMMIT_MSG)" || echo "No changes to commit."
	@echo "✅ Changes committed successfully."

push:
	@echo "Pushing changes to remote repository..."
	git push origin main
	@echo "✅ All tasks completed successfully."


expose-postgres:
	@echo "Forward ports for postgres"
	kubectl port-forward svc/postgres 5432:5432 -n db &

expose-nats:
	@echo "Forward ports for NATS"
	kubectl port-forward svc/nats 4222:4222 -n messaging &

terraform-init:
	@echo "Initializing Terraform..."
	cd terraform && terraform init

terraform-apply:
	@echo "Applying Terraform configuration..."
	cd terraform && terraform apply -auto-approve

terraform-destroy:
	@echo "Destroying Terraform resources..."
	cd terraform && terraform destroy -auto-approve
