# Amazon EMR with Dask

Scripts and documentation on how to deploy an Amazon EMR cluster with Dask for running the high spatial resolution modelling can be found here.
- [spark-emr-hello-world](spark-emr-hello-world) is a quick-start example on setting up an Amazon EMR cluster with Spark using AWS CLI and running a test job.
- [dask-emr-hello-world](dask-emr-hello-world) is a quick-start example on setting up an Amazon EMR cluster with Dask using AWS CLI and running a test job.
- [conda-pack](conda-pack) Setting up an Amazon EMR cluster with pre-installed packages
- [dask-ecs](dask-ecs) Setting up Dask with Amazon ECS and Docker
- [dask-emr-terraform](dask-emr-terraform) Terraform module for Amazon EMR with Dask
- [cgc-test](cgc-test) contains a test analysis notebook and illustrates how to set up the environment.

```bash
aws ce get-cost-and-usage --time-period Start=2021-03-01,End=2021-03-31 --metrics "BlendedCost" "UnblendedCost" "UsageQuantity" --granularity MONTHLY
```

Example pricing:
- The price for an on-demand `m5.xlarge` EC2 instance is 0.192 USD/hour. There is an additional EMR price of 0.048 USD/hour. For a 3-node EMR cluster, the total price is 0.72 USD/hour or 17.28 USD/day.
- The price for an on-demand `m5.24xlarge` EC2 instance is 4.608 USD/hour. There is an additional EMR price of 0.27 USD/hour. For a 3-node EMR cluster, the total price is 14.63 USD/hour or 351.22 USD/day.
