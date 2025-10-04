@echo off

@echo config_server
docker exec -it config_server mongosh --port 27019 --quiet --eval "rs.initiate({ _id: 'config_server', configsvr: true, members: [ { _id: 0, host: 'config_server:27019' } ] })"

@echo shard_1
docker exec -it shard_1 mongosh --port 27018 --eval "rs.initiate({ _id: 'shard_1', members: [ { _id: 0, host: 'shard_1:27018' } ] })"

@echo shard_2
docker exec -it shard_2 mongosh --port 27018 --eval "rs.initiate({ _id: 'shard_2', members: [ { _id: 1, host: 'shard_2:27018' } ] })"

@echo mongos_router operations
docker exec -it mongos_router mongosh --port 27017 --eval "sh.addShard('shard_1/shard_1:27018'); sh.addShard('shard_2/shard_2:27018'); sh.enableSharding('somedb'); sh.shardCollection('somedb.helloDoc', { 'name': 'hashed' });"

@echo Insert test data and count documents
docker exec -it mongos_router mongosh --port 27017 --eval "db = db.getSiblingDB('somedb'); for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:'ly'+i}); print('Total documents: ' + db.helloDoc.countDocuments());"

@echo shard_1 count documents
docker exec -it shard_1 mongosh --port 27018 --eval "db = db.getSiblingDB('somedb'); print('shard_1: ' + db.helloDoc.countDocuments());"

@echo shard_2 count documents
docker exec -it shard_2 mongosh --port 27018 --eval "db = db.getSiblingDB('somedb'); print('shard_2: ' + db.helloDoc.countDocuments());"
