build:
	docker build --build-arg USER=$(USER) --build-arg USER_ID=$(shell id -u) -t coding-agent-container:latest .
