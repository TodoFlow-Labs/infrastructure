.PHONY: commit push

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
