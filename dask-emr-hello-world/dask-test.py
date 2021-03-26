from dask.distributed import Client

client = Client("tcp://localhost:8786")
client

def square(x):
    return x**2

def neg(x):
    return -x

A = client.map(square, range(10))
B = client.map(neg, A)
total = client.submit(sum, B)
total.result()

total
client.gather(A)
