build:
	docker buildx build --platform linux/amd64,linux/arm64 --target export -o type=local,dest=./dist .