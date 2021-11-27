rm-bc:
	docker rmi bc || true

build-bc:
	docker rmi bc || true
	./prepare_bc.sh
	docker build -t bc -f ./Dockerfile .

run-bc:
	docker run --rm -it -e INPUT=${INPUT} bc
