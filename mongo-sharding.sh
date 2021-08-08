# clean up.

echo 'remove data files.'
rm -rf data

# create folder structure for config servers.
echo 'create folder structure for config servers.'
mkdir -p data/csrs/csrs{1,2,3}/{db,log} \
         data/sh01/sh01{1,2,3}/{db,log} \
         data/sh02/sh02{1,2,3}/{db,log} \
         data/sh03/sh03{1,2,3}/{db,log} \
         data/router/log \

# start config servers.
echo 'start config servers.'
mongod --configsvr --replSet configRS --bind_ip_all --dbpath data/csrs/csrs1/db/ --logpath data/csrs/csrs1/log/csrs1.log --logappend --port 30000 --fork
mongod --configsvr --replSet configRS --bind_ip_all --dbpath data/csrs/csrs2/db/ --logpath data/csrs/csrs2/log/csrs2.log --logappend --port 30001 --fork
mongod --configsvr --replSet configRS --bind_ip_all --dbpath data/csrs/csrs3/db/ --logpath data/csrs/csrs3/log/csrs3.log --logappend --port 30002 --fork

sleep 15s

# config them to be part of the same replica set.
# connect to one server and initiate the set.
echo 'config replica set for config servers.'
mongosh --port 30000 << 'EOF'
config = { _id: "configRS", members:[
          { _id : 0, host : "localhost:30000" },
          { _id : 1, host : "localhost:30001" },
          { _id : 2, host : "localhost:30002" }]};
rs.initiate(config)
EOF

# start mongos
echo 'start and config mongos.'
mongos --configdb configRS/localhost:30000,localhost:30001,localhost:30002 --bind_ip_all --logpath data/router/log/mongos.log --logappend --port 30009 --fork

# start shard 01
echo 'start shard 01.'
mongod --shardsvr --replSet sh01 --bind_ip_all --dbpath data/sh01/sh011/db/ --logpath data/sh01/sh011/log/sh011.log --logappend --port 30003 --fork
mongod --shardsvr --replSet sh01 --bind_ip_all --dbpath data/sh01/sh012/db/ --logpath data/sh01/sh012/log/sh012.log --logappend --port 30004 --fork
mongod --shardsvr --replSet sh01 --bind_ip_all --dbpath data/sh01/sh013/db/ --logpath data/sh01/sh013/log/sh013.log --logappend --port 30005 --fork

# start shard 02
echo 'start shard 02.'
mongod --shardsvr --replSet sh02 --bind_ip_all --dbpath data/sh02/sh021/db/ --logpath data/sh02/sh021/log/sh021.log --logappend --port 30006 --fork
mongod --shardsvr --replSet sh02 --bind_ip_all --dbpath data/sh02/sh022/db/ --logpath data/sh02/sh022/log/sh022.log --logappend --port 30007 --fork
mongod --shardsvr --replSet sh02 --bind_ip_all --dbpath data/sh02/sh023/db/ --logpath data/sh02/sh023/log/sh023.log --logappend --port 30008 --fork

# start shard 03
echo 'start shard 03.'
mongod --shardsvr --replSet sh03 --bind_ip_all --dbpath data/sh03/sh031/db/ --logpath data/sh03/sh031/log/sh031.log --logappend --port 30020 --fork
mongod --shardsvr --replSet sh03 --bind_ip_all --dbpath data/sh03/sh032/db/ --logpath data/sh03/sh032/log/sh032.log --logappend --port 30021 --fork
mongod --shardsvr --replSet sh03 --bind_ip_all --dbpath data/sh03/sh033/db/ --logpath data/sh03/sh033/log/sh033.log --logappend --port 30022 --fork

sleep 15s

# config shard 01
echo 'config shard 01.'
mongosh --port 30003 << 'EOF'
config = { _id: "sh01", members:[
          { _id : 0, host : "localhost:30003" },
          { _id : 1, host : "localhost:30004" },
          { _id : 2, host : "localhost:30005" }]};
rs.initiate(config)
EOF

sleep 15s

# config shard 02
echo 'config shard 02.'
mongo --port 30006 << 'EOF'
config = { _id: "sh02", members:[
          { _id : 0, host : "localhost:30006" },
          { _id : 1, host : "localhost:30007" },
          { _id : 2, host : "localhost:30008" }]};
rs.initiate(config)
EOF

sleep 15s

# config shard 03
echo 'config shard 03.'
mongo --port 30020 << 'EOF'
config = { _id: "sh03", members:[
          { _id : 0, host : "localhost:30020" },
          { _id : 1, host : "localhost:30021" },
          { _id : 2, host : "localhost:30022" }]};
rs.initiate(config)
EOF

sleep 15s

# add shards to config server
echo 'add shards 01 and 02.'
mongosh --port 30009 << 'EOF'
db.adminCommand( { addshard : "sh01/"+"localhost:30003" } );
db.adminCommand( { addshard : "sh02/"+"localhost:30006" } );
db.adminCommand( { addshard : "sh03/"+"localhost:30020" } );
sh.status();
EOF

echo 'Done creating shard cluster.'