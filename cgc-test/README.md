# Test Job with CGC

* Environment configured as in https://github.com/escience-academy/tutorial-cgc/blob/main/environment.yml, using `conda` and `pip`:
```shell script
conda install -c conda-forge gdal
pip install rasterio xarray clustering-geodata-cubes
```
* Environment packed to setup YARN cluster:
```shell script
conda pack -o environment-cgc.tar.gz
```
* [This notebook](./cgc-test.ipynb) includes a test co-clustering analysis.