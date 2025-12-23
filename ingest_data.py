# import needed libraries
import pandas as pd
import rasterio 
from rasterio.merge import merge
import glob
import os

# need to stich the 4 chosen .tif files into one master image
def merge_tiles():
    print("Locating and stiching satellite images...")

    search_path = '/Users/kellen/Developer/forest_learning/data'
    tiles = glob.glob(search_path)

    if not tiles:
        print("Error: no satellite image tiles were found")
        return None
    
    # loop for .tif files and build list
    src_files_to_mosaic = []
    for _ in tiles:
        src = rasterio.open(_)
        src_files_to_mosaic.append(src)

    # merge
    mosaic, out_trans = merge(src_files_to_mosaic)

    out_meta = src_files_to_mosaic[0].meta.copy()
    out_meta.update({
        "driver": "GTiff",
        "height": mosaic.shape[1],
        "width": mosaic.shape[2],
        "transform": out_trans,
        "crs": src_files_to_mosaic[0].crs
    })

    merged_filename = 'full_merge_canopy.tif'
    with rasterio.open(merged_filename, 'w', **out_meta) as destination:
        destination.write(mosaic
        )
    print(f"Creation of {merged_filename} was successful.")
    return merged_filename

# # function that pulls in .csv and .tif files - only select columns are retained to keep size manageable
# def ingest_fia_data(plot_path, cond_path, tree_path, raster_path):
#     print("Starting ingestion...")

#     plots = pd.read_csv('data/TN_PLOT.csv', usecols=['CN', 'LAT', 'LON', 'INVYR'])
#     conds = pd.read_csv('data/TN_COND.csv', usecols=['PLT_CN', 'CONDID', 'FORTYPCD', 'STNDAGE'])
#     trees = pd.read_csv('data/TN_TREE.csv', usecols=['PLT_CN', 'CONDID', 'STATUSCD', 'SPCD', 'HT', 'DIA'])

#     print("Joining data...")

#     df = pd.merge(conds, plots, left_on='PLT_CN', right_on='CN').drop(columns=['CN'])
#     df = pd.merge(trees, df, on=['PLT_CN', 'CONDID'])

#     print("Obtaining LiDar canopy height data...")
#     with rasterio.open('')
