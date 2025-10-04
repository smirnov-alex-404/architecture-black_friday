#!/bin/bash

config_server
docker compose exec -T config_server mongosh --port 27019 --quiet <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "config_server:27019" }
    ]
  }
)
exit()
EOF

shard_1

docker compose exec -T shard_1_repl_1 mongosh --port 27018 --quiet <<EOF
rs.initiate(
    {
      _id : "shard_1",
      members: [
        { _id : 0, host : "shard_1_repl_1:27018" },
        { _id : 1, host : "shard_1_repl_2:27018" },
        { _id : 2, host : "shard_1_repl_3:27018" }
      ]
    }
)
exit()
EOF

shard_2
docker compose exec -T shard_2_repl_1 mongosh --port 27018 --quiet <<EOF
rs.initiate(
    {
      _id : "shard_2",
      members: [
        { _id : 0, host : "shard_2_repl_1:27018" },
        { _id : 1, host : "shard_2_repl_2:27018" },
        { _id : 2, host : "shard_2_repl_3:27018" }
      ]
    }
  )
exit()
EOF

docker compose exec -T mongos_router mongosh --port 27017 --quiet <<EOF
sh.addShard( "shard_1/shard_1_repl_1:27018,shard_1_repl_2:27018,shard_1_repl_3:27018")
sh.addShard( "shard_2/shard_2_repl_1:27018,shard_2_repl_2:27018,shard_2_repl_3:27018")

sh.enableSharding("somedb")
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

use somedb

for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})

db.helloDoc.countDocuments()
exit()
EOF

echo shard_1 count documents
docker compose exec -T shard_1_repl_1 mongosh --port 27018 --quiet <<EOF
db = db.getSiblingDB('somedb')
print('shard_1: ' + db.helloDoc.countDocuments())
EOF

echo shard_2 count documents
docker compose exec -T shard_2_repl_1 mongosh --port 27018 --quiet <<EOF
db = db.getSiblingDB('somedb')
print('shard_2: ' + db.helloDoc.countDocuments())
EOF
