.SILENT:

DOCKER_COMPOSE = docker-compose
DOCKER_PHP_CONTAINER_EXEC = $(DOCKER_COMPOSE) exec php
DOCKER_DB_CONTAINER_EXEC = $(DOCKER_COMPOSE) exec database
DOCKER_PHP_EXECUTABLE_CMD = php -dmemory_limit=1G

help:           ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

all: start-recreate reinstall

start:          ## Start app
	$(DOCKER_COMPOSE) up -d

start-recreate: ## Start app with full rebuild
	$(DOCKER_COMPOSE) up -d  --build --force-recreate --remove-orphans

stop:           ## Stop app
	$(DOCKER_COMPOSE) stop

remove: stop    ## Stop and remove app
	$(DOCKER_COMPOSE) rm -f

logs:           ## Show app logs
	$(DOCKER_COMPOSE) logs -ft --tail=50

exec-php:       ## Enter PHP container shell
	$(DOCKER_PHP_CONTAINER_EXEC) bash

exec-db:        ## Enter DB container shell
	$(DOCKER_DB_CONTAINER_EXEC) bash

install: start  ## Install app after start
	$(DOCKER_PHP_CONTAINER_EXEC) composer install --working-dir=src --no-progress --no-suggest --optimize-autoloader --prefer-dist --no-dev
ifeq (,$(wildcard ./src/bb-config.php))
	cp ./src/bb-config-sample.php ./src/bb-config.php
	$(DOCKER_PHP_CONTAINER_EXEC) $(DOCKER_PHP_EXECUTABLE_CMD) ./bin/prepare.php
endif

reinstall:      ## Reinstall app
	rm -rf ./src/bb-config.php
	make install

test: install	## Run app tests
	echo "Running unit tests"
	echo > ./src/bb-data/log/application.log
	echo > ./src/bb-data/log/php_error.log
	$(DOCKER_PHP_CONTAINER_EXEC) composer install --working-dir=src --no-progress --no-suggest --optimize-autoloader --prefer-dist
	$(DOCKER_PHP_CONTAINER_EXEC) ./src/bb-vendor/bin/phpunit --dont-report-useless-tests ./tests/bb-modules/

release:		## App release
	echo $(TRAVIS_BUILD_DIR)
	echo $(TRAVIS_BUILD_ID)
	echo $(TRAVIS_BUILD_NUMBER)
	echo $(TRAVIS_JOB_ID)
	echo $(TRAVIS_TAG)
	npm install -g grunt-cli
	npm install
	grunt
	ant release

release-open:
	docker run -d -p 8741:80 --mount type=bind,source="$(PWD)"/build/source,target=/var/www/public pensiero/apache-php-mysql:php7.4
	open http://localhost:8741/install/
