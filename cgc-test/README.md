# Test Job with CGC

This folder contains notebooks and scripts that illustrate how to run co-clustering analysis using the Dask-based 
implementation of [clustering-geodata-cubes (CGC)](http://github.com/phenology/cgc).

## Environment 

In order to run the notebooks, the environment needs to be configured as for the 
[CGC tutorial](https://github.com/escience-academy/tutorial-cgc), using `conda` and `pip`:
```shell script
conda install -c conda-forge gdal
pip install rasterio xarray clustering-geodata-cubes
```
The environment is then packed to configure the YARN cluster:
```shell script
conda pack -o environment-cgc.tar.gz
```

## Notebooks

The following notebooks are available:
* [cgc-test.ipynb](./cgc-test.ipynb) includes a test analysis on fake/small datasets.
* [cgc-conus-leaf.ipynb](./cgc-conus-leaf.ipynb) illustrates a co-clustering analysis using a real medium-sized dataset 
  (first-leaf spring-index for the contiguous United States).