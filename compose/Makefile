build-run-compose-bc:
	# ./prepare_bc.sh
	# docker-compose -f compose-bc.yml up --build
	docker-compose -f compose-bc.yml up

run-compose-busybox:
	docker-compose -f compose-busybox.yml up

stop-compose:
	docker-compose -f compose-bc.yml down
	docker-compose -f compose-busybox.yml down
	docker volume ls -q | grep -E bc-.*?exch_vol | xargs docker volume rm
