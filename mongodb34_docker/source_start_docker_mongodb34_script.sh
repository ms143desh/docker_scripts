#!/bin/bash
echo "Docker Compose for MongoDB ReplicaSet and Sharded cluster"
docker-compose -f source_docker_compose_mongodb34.yml up -d

echo "Wait for MongoDB clusters to start"
sleep 30

# Init the replica sets (use the MONGOS host)
echo "MongoShell - initiate configuration server mongocfg1"
docker exec -it 34mongossource1 bash -c "echo 'rs.initiate({_id: \"34mongosourcers1conf\",configsvr: true, members: [{ _id : 0, host : \"34mongosourcecfg1:27321\", priority: 2 },{ _id : 1, host : \"34mongosourcecfg2:27321\" }, { _id : 2, host : \"34mongosourcecfg3:27321\" }]})' | mongo --host 34mongosourcecfg1:27321"
sleep 10

echo "MongoShell - initiate Sharder server mongors1n1"
docker exec -it 34mongossource1 bash -c "echo 'rs.initiate({_id : \"34mongosourcers1\", members: [{ _id : 0, host : \"34mongosourcers1n1:27324\", priority: 2 },{ _id : 1, host : \"34mongosourcers1n2:27324\" },{ _id : 2, host : \"34mongosourcers1n3:27324\" }]})' | mongo --host 34mongosourcers1n1:27324"
sleep 10

# ADD TWO SHARDS (mongors1, and mongors2)
echo "MongoShell - Add shard mongors2n1"
docker exec -it 34mongossource1 bash -c "echo 'sh.addShard(\"34mongosourcers1/34mongosourcers1n1:27324,34mongosourcers1n2:27324,34mongosourcers1n3:27324\")' | mongo --host 34mongosourcers1n1:27324"
sleep 10




echo "MongoShell - run command - rs.status()"
docker exec -it 34mongossource1 bash -c "echo 'rs.status()' | mongo --host 34mongosourcers1n1:27324"
sleep 10

echo "MongoShell - run command - db.adminCommand({listShards:1})"
docker exec -it 34mongossource1 bash -c "echo 'db.adminCommand({listShards:1})' | mongo --host 34mongosourcers1n1:27324"
sleep 10

echo "MongoShell - run command - db.printShardingStatus()"
docker exec -it 34mongossource1 bash -c "echo 'db.printShardingStatus()' | mongo --host 34mongosourcers1n1:27324"
sleep 10

echo "MongoShell - run command - db.hostInfo()"
docker exec -it 34mongossource1 bash -c "echo 'db.hostInfo()' | mongo --host 34mongosourcers1n1:27324"
sleep 10

echo "MongoShell - run command - db.stats()"
docker exec -it 34mongossource1 bash -c "echo 'db.stats()' | mongo --host 34mongosourcers1n1:27324"
sleep 10

echo "MongoShell - run command - db.serverStatus()"
docker exec -it 34mongossource1 bash -c "echo 'db.serverStatus()' | mongo --host 34mongosourcers1n1:27324"
