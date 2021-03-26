import time
from dask_yarn import YarnCluster
from dask.distributed import Client

# Create a cluster
cluster = YarnCluster()

# Connect to the cluster
client = Client(cluster)
print(client)

cluster.scale(2)

def square(x):
    return x**2

def neg(x):
    return -x

A = client.map(square, range(10))
B = client.map(neg, A)
total = client.submit(sum, B)
print(total.result())

print(total)
print(client.gather(A))
