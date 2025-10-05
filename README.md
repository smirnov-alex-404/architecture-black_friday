# pymongo-api

## Diagram

[drawio diagram](diagrams/diagram.drawio)


![diagram.png](diagrams/diagram.png)

## Как запустить

Запускаем итоговую версию mongodb и приложение

```shell
cd sharding-repl-cache
```

```shell
docker compose up -d
```

Заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```

![shard_repl_script_output.jpg](mongo-sharding-repl/img/shard_repl_script_output.jpg)

## Как проверить

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080

### Если вы запускаете проект на предоставленной виртуальной машине

Узнать белый ip виртуальной машины

```shell
curl --silent http://ifconfig.me
```

Откройте в браузере http://<ip виртуальной машины>:8080

![shard-repl-cache-api.jpg](sharding-repl-cache/img/shard-repl-cache-api.jpg)

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://<ip виртуальной машины>:8080/docs

Второй и последующие вызовы эндпоинта /<collection_name>/users выполняются <1000мс

![shard-repl-cache.jpg](sharding-repl-cache/img/shard-repl-cache.jpg)
