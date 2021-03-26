import time
from dask_yarn import YarnCluster
from dask.distributed import Client

# Create a cluster
cluster = YarnCluster()

# Connect to the cluster
# client = Client(cluster)

cluster.scale(2)

time.sleep(100000)
