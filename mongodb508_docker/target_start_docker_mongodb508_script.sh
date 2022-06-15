#!/bin/bash
echo "Docker Compose for MongoDB ReplicaSet and Sharded cluster"
docker-compose -f target_docker_compose_mongodb508.yml up -d

echo "Wait for MongoDB clusters to start"
sleep 30

# Init the replica sets (use the MONGOS host)
echo "MongoShell - initiate configuration server mongocfg1"
docker exec -it mongostarget1 bash -c "echo 'rs.initiate({_id: \"mongotargetrs1conf\",configsvr: true, members: [{ _id : 0, host : \"mongoctargetfg1:27019\", priority: 2 },{ _id : 1, host : \"mongoctargetfg2:27019\" }, { _id : 2, host : \"mongoctargetfg3:27019\" }]})' | mongo --host mongoctargetfg1:27019"
sleep 10

echo "MongoShell - initiate Sharder server mongors1n1"
docker exec -it mongostarget1 bash -c "echo 'rs.initiate({_id : \"mongotargetrs1\", members: [{ _id : 0, host : \"mongotargetrs1n1:27018\", priority: 2 },{ _id : 1, host : \"mongotargetrs1n2:27018\" },{ _id : 2, host : \"mongotargetrs1n3:27018\" }]})' | mongo --host mongotargetrs1n1:27018"
sleep 10

# ADD TWO SHARDS (mongors1, and mongors2)
echo "MongoShell - Add shard mongors2n1"
docker exec -it mongostarget1 bash -c "echo 'sh.addShard(\"mongotargetrs1/mongotargetrs1n1:27018,mongotargetrs1n2:27018,mongotargetrs1n3:27018\")' | mongo --host mongotargetrs1n1:27018"
sleep 10




echo "MongoShell - run command - rs.status()"
docker exec -it mongostarget1 bash -c "echo 'rs.status()' | mongo --host mongotargetrs1n1:27018"
sleep 10

echo "MongoShell - run command - db.adminCommand({listShards:1})"
docker exec -it mongostarget1 bash -c "echo 'db.adminCommand({listShards:1})' | mongo --host mongotargetrs1n1:27018"
sleep 10

echo "MongoShell - run command - db.printShardingStatus()"
docker exec -it mongostarget1 bash -c "echo 'db.printShardingStatus()' | mongo --host mongotargetrs1n1:27018"
sleep 10

echo "MongoShell - run command - db.hostInfo()"
docker exec -it mongostarget1 bash -c "echo 'db.hostInfo()' | mongo --host mongotargetrs1n1:27018"
sleep 10

echo "MongoShell - run command - db.stats()"
docker exec -it mongostarget1 bash -c "echo 'db.stats()' | mongo --host mongotargetrs1n1:27018"
sleep 10

echo "MongoShell - run command - db.serverStatus()"
docker exec -it mongostarget1 bash -c "echo 'db.serverStatus()' | mongo --host mongotargetrs1n1:27018"
