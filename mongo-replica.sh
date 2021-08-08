# sh03 is a replica set and will be added to cluster as a shard.
echo 'remove sh03 data.'
rm -rf data/sh03

echo 'create data and log for sh03.'
mkdir -p data/sh03/sh03{1,2,3}/{db,log}

echo 'start servers for sh03.'
mongod --replSet sh03 --bind_ip_all --dbpath data/sh03/sh031/db/ --logpath data/sh03/sh031/log/sh031.log --logappend --port 30020 --fork
mongod --replSet sh03 --bind_ip_all --dbpath data/sh03/sh032/db/ --logpath data/sh03/sh032/log/sh032.log --logappend --port 30021 --fork
mongod --replSet sh03 --bind_ip_all --dbpath data/sh03/sh033/db/ --logpath data/sh03/sh033/log/sh033.log --logappend --port 30022 --fork

echo 'config replica set for sh03 servers.'
mongosh --port 30020 << 'EOF'
config = { _id: "sh03", members:[
          { _id : 0, host : "localhost:30020" },
          { _id : 1, host : "localhost:30021" },
          { _id : 2, host : "localhost:30022" }]};
rs.initiate(config)
EOF

echo 'Done'
