#!/bin/bash
echo "Docker Compose for MongoDB ReplicaSet and Sharded cluster"
docker-compose -f source_docker_compose_mongodb508_copy.yml up -d

echo "Wait for MongoDB clusters to start"
sleep 30

# Init the replica sets (use the MONGOS host)
echo "MongoShell - initiate configuration server mongocfg1"
docker exec -it mongossource1 bash -c "echo 'rs.initiate({_id: \"mongosourcers1conf\",configsvr: true, members: [{ _id : 0, host : \"mongosourcecfg1:27021\", priority: 2 },{ _id : 1, host : \"mongosourcecfg2:27021\" }, { _id : 2, host : \"mongosourcecfg3:27021\" }]})' | mongo --host mongosourcecfg1:27021"
sleep 10

echo "MongoShell - initiate Sharder server mongors1n1"
docker exec -it mongossource1 bash -c "echo 'rs.initiate({_id : \"mongosourcers1\", members: [{ _id : 0, host : \"mongosourcers1n1:27024\", priority: 2 },{ _id : 1, host : \"mongosourcers1n2:27024\" },{ _id : 2, host : \"mongosourcers1n3:27024\" }]})' | mongo --host mongosourcers1n1:27024"
sleep 10

# ADD TWO SHARDS (mongors1, and mongors2)
echo "MongoShell - Add shard mongors2n1"
docker exec -it mongossource1 bash -c "echo 'sh.addShard(\"mongosourcers1/mongosourcers1n1:27024,mongosourcers1n2:27024,mongosourcers1n3:27024\")' | mongo"
sleep 10




echo "MongoShell - run command - rs.status()"
docker exec -it mongossource1 bash -c "echo 'rs.status()' | mongo"
sleep 10

echo "MongoShell - run command - db.adminCommand({listShards:1})"
docker exec -it mongossource1 bash -c "echo 'db.adminCommand({listShards:1})' | mongo"
sleep 10

echo "MongoShell - run command - db.printShardingStatus()"
docker exec -it mongossource1 bash -c "echo 'db.printShardingStatus()' | mongo"
sleep 10

echo "MongoShell - run command - db.hostInfo()"
docker exec -it mongossource1 bash -c "echo 'db.hostInfo()' | mongo"
sleep 10

echo "MongoShell - run command - db.stats()"
docker exec -it mongossource1 bash -c "echo 'db.stats()' | mongo"
sleep 10

echo "MongoShell - run command - db.serverStatus()"
docker exec -it mongossource1 bash -c "echo 'db.serverStatus()' | mongo"
