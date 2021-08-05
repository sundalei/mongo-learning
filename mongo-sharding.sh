# clean up.
echo 'kill existing processes.'
killall mongod
killall mongos

echo 'remove data files.'
rm -rf demo-shard/csrs
rm -rf demo-shard/sh01
rm -rf demo-shard/sh02

# create folder structure for config servers.
echo 'create folder structure for config servers.'
mkdir -p demo-shard/csrs/csrs1/db \
         demo-shard/csrs/csrs1/log \
         demo-shard/csrs/csrs2/db \
         demo-shard/csrs/csrs2/log \
         demo-shard/csrs/csrs3/db \
         demo-shard/csrs/csrs3/log \
         demo-shard/router/log \
         demo-shard/sh01/sh011/db \
         demo-shard/sh01/sh011/log \
         demo-shard/sh01/sh012/db \
         demo-shard/sh01/sh012/log \
         demo-shard/sh01/sh013/db \
         demo-shard/sh01/sh013/log \
         demo-shard/sh02/sh021/db \
         demo-shard/sh02/sh021/log \
         demo-shard/sh02/sh022/db \
         demo-shard/sh02/sh022/log \
         demo-shard/sh02/sh023/db \
         demo-shard/sh02/sh023/log \

# start config servers.
echo 'starting config servers'
mongod -f /Users/magoookaminari/study/mongodb/mongo-learning/demo-shard/csrs1.conf --fork
mongod -f /Users/magoookaminari/study/mongodb/mongo-learning/demo-shard/csrs2.conf --fork
mongod -f /Users/magoookaminari/study/mongodb/mongo-learning/demo-shard/csrs3.conf --fork

# start shard 01
mongod -f /Users/magoookaminari/study/mongodb/mongo-learning/demo-shard/sh011.conf --fork
mongod -f /Users/magoookaminari/study/mongodb/mongo-learning/demo-shard/sh012.conf --fork
mongod -f /Users/magoookaminari/study/mongodb/mongo-learning/demo-shard/sh013.conf --fork

# start shard 02
mongod -f /Users/magoookaminari/study/mongodb/mongo-learning/demo-shard/sh021.conf --fork
mongod -f /Users/magoookaminari/study/mongodb/mongo-learning/demo-shard/sh022.conf --fork
mongod -f /Users/magoookaminari/study/mongodb/mongo-learning/demo-shard/sh023.conf --fork

sleep 15s

# config them to be part of the same replica set.
# connect to one server and initiate the set
mongo --port 30000 << 'EOF'
config = { _id: "csrs", members:[
          { _id : 0, host : "localhost:30000" },
          { _id : 1, host : "localhost:30001" },
          { _id : 2, host : "localhost:30002" }]};
rs.initiate(config)
EOF

# start mongos
mongos -f /Users/magoookaminari/study/mongodb/mongo-learning/demo-shard/mongos.conf --fork

sleep 15s

# config shard 01
mongo --port 30003 << 'EOF'
config = { _id: "sh01", members:[
          { _id : 0, host : "localhost:30003" },
          { _id : 1, host : "localhost:30004" },
          { _id : 2, host : "localhost:30005" }]};
rs.initiate(config)
EOF

sleep 15s

# config shard 02
mongo --port 30006 << 'EOF'
config = { _id: "sh02", members:[
          { _id : 0, host : "localhost:30006" },
          { _id : 1, host : "localhost:30007" },
          { _id : 2, host : "localhost:30008" }]};
rs.initiate(config)
EOF

# add shard 01 and shard 02 to config server
mongo --port 30009 << 'EOF'
db.adminCommand( { addshard : "sh01/"+"localhost:30003" } );
db.adminCommand( { addshard : "sh02/"+"localhost:30006" } );
sh.status();
EOF

echo 'Done creating shard cluster.'