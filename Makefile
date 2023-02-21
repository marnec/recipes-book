.DEFAULT_GOAL := help

# prende i parametri e li converte
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)

# legge il file .env nella stessa cartella
ifneq (,$(wildcard ./dev.env))
    include dev.env
    export
endif

##help: @ Mostra tutti i comandi di questo makefile
help:
	@fgrep -h "##" $(MAKEFILE_LIST)| sort | fgrep -v fgrep | tr -d '##'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	
##start: @ Avvia l'applicazione esponendo il backend sulla porta 3000 e il frontend sulla porta 4200
start:build 
	docker-compose --env-file ./dev.env up -d

##stop: @ Ferma l'applicazione
stop: 
	docker-compose --env-file ./dev.env down

##build: @ Esegue la build delle immagini
build:
	export OCI_KEY="$(shell cat ${OCI_KEY_FILE})"
	docker-compose build

##logs: @ Mostra i logs di tutti i containers
logs:
	docker-compose logs --follow

##restart: @ Fa ripartire l'applicazione
restart: stop start

##code: @ Apre vscode
code: 
	code workspace.code-workspace

##be-logs: @ Mostra i logs del backend
be-logs: 
	docker logs --follow "backend-${APP_NAME}"

##fe-logs: @ Mostra i logs del frontend
fe-logs: 
	docker logs --follow "frontend-${APP_NAME}"

##be-sh: @ Accede alla shell del backend
be-sh: 
	docker exec -it "backend-${APP_NAME}" bash

##fe-sh: @ Accede alla shell del frontend
fe-sh: 
	docker exec -it "frontend-${APP_NAME}" bash

##migrate: @ Crea una migration 
migrate:
	@docker exec -it "backend-${APP_NAME}" npm run typeorm:generate --name=$(RUN_ARGS)

##run-migration: @ Lancia le migrations
run-migration:
	@docker exec -it "backend-${APP_NAME}" npm run typeorm:run

##revert-migration: @ Revert dell'ultima migration
revert-migration:
	@docker exec -it "backend-${APP_NAME}" npm run typeorm:revert

