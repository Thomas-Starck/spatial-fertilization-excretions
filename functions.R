#function to save csv files in a directory. If directory does not exist, creates it
f_save_csv_files <- function(file_to_save, output_path, file_name){
  
  # Create the directory recursively if it doesn't exist
  if (!file.exists(output_path)) {
    dir.create(output_path, recursive = TRUE)
  }
  
  # Write the CSV file
  write_csv(file_to_save, file = file.path(output_path, file_name))
}

#function to save parquet files in a directory. If directory does not exist, creates it
f_save_parquet_files <- function(file_to_save, output_path, file_name){
  
  # Create the directory recursively if it doesn't exist
  if (!file.exists(output_path)) {
    dir.create(output_path, recursive = TRUE)
  }
  
  # Write the parquet file
  arrow::write_parquet(file_to_save, sink = file.path(output_path, file_name))
}


# function to transform file of discrete spatial points to raster for area, N P and K mineral, and N organic
f_prepare_raster <- function(
    dataset, 
    var_area, var_Nmin, var_Pmin, var_Kmin, var_Norg,
    resolution_meters, background_sf
){
  
  #create raster template resolution with resolution
  extent <- raster::extent(dataset)
  raster_template <- raster::raster(extent, res = resolution_meters)
  raster::crs(raster_template) <- st_crs(background_sf)
  
  #create raster
  raster_data <- raster::rasterize(dataset, raster_template, fun = "sum")
  raster_df <- raster::as.data.frame(raster_data, xy = TRUE)
  
  raster_df <- raster_df %>%
    
    #transform for variable per our resolution to variable per km2
    mutate(
      
      #transform to ha/km2
      ha_per_km2 = ({{ var_area }})/km2_resolution,
      
      #transform to tNmin/km2 (on total area) and kgNmin/ha (on actual agri land area)
      tNmin_per_km2 = ({{ var_Nmin }})/1000/km2_resolution, 
      mean_kgNmin_per_ha = tNmin_per_km2*1000/ha_per_km2,
      
      #transform to tPmin/km2 and kgPmin/ha
      tPmin_per_km2 = ({{ var_Pmin }})/1000/km2_resolution, 
      mean_kgPmin_per_ha = tPmin_per_km2*1000/ha_per_km2,
      
      #transform to tKmin/km2 and kgKmin/ha
      tKmin_per_km2 = ({{ var_Kmin }})/1000/km2_resolution, 
      mean_kgKmin_per_ha = tKmin_per_km2*1000/ha_per_km2,
      
      #transform to tNorg/km2 and kgNorg/ha
      tNorg_per_km2 = ({{ var_Norg }})/1000/km2_resolution, 
      mean_kgNorg_per_ha = tNorg_per_km2*1000/ha_per_km2,
      
      
    )
  
  #remove empty pixels
  raster_df <- raster_df %>%
    filter(is.na(ha_per_km2)==F)
  
  return(raster_df)
  
}

# function to create categories of numerical variable and their labels
f_categorize_densities <- function(dataset, column_name, breaks_values, labels_values){
  
  dataset$category <-
    cut(
      dataset[[column_name]],
      breaks = breaks_values,
      labels = labels_values
      )
  
  return(dataset)
}

# function to map variable, with categories as color legend
f_grap_map_raster <- function(
    dataset, variable_category, 
    unit, resolution_meters, background_sf, background_color)
{
  
  gg <- ggplot() +
    geom_sf(data = background_sf, fill=background_color) +
    geom_tile(
      data = dataset,
      aes(x = x, y = y, fill = {{ variable_category }})
    )  +
    scale_fill_discrete(na.translate = FALSE) + #remove NAs for empty tiles in legend
    labs(
      fill=unit, x="", y="", 
      caption=paste0(
        "1 pixel = ", km2_resolution, " km2\n",
        "square ", round(resolution_meters/10^3, 1), "km x ", round(resolution_meters/10^3, 1), "km"
      )
    ) +
    coord_sf(datum = NA) #remove x and y axis notations
  
  return(gg)
  
}


#function to save a graph
f_save_graph_pdf_png <- function(gg_plot, path_name, file_name, resolution, height, width){
  
  #pdf
  ggsave(
    paste0(path_name, file_name, ".pdf"),
    create.dir = T,
    bg="white",
    dpi=resolution, width=width, height=height,
  )
  
  #png
  ggsave(
    paste0(path_name, file_name, ".png"),
    create.dir = T,
    bg="white",
    dpi=resolution, width=width, height=height,
  )
  
}



#loads core tidyverse package
library(tidyverse) #loads multiple packages (see https://tidyverse.tidyverse.org/)

#core tidyverse packages loaded:
# ggplot2, for data visualisation. https://ggplot2.tidyverse.org/
# dplyr, for data manipulation. https://dplyr.tidyverse.org/
# tidyr, for data tidying. https://tidyr.tidyverse.org/
# readr, for data import. https://readr.tidyverse.org/
# purrr, for functional programming. https://purrr.tidyverse.org/
# tibble, for tibbles, a modern re-imagining of data frames. https://tibble.tidyverse.org/
# stringr, for strings. https://stringr.tidyverse.org/
# forcats, for factors. https://forcats.tidyverse.org/
# lubridate, for date/times. https://lubridate.tidyverse.org/

#also loads the following packages (less frequently used):
# Working with specific types of vectors:
#     hms, for times. https://hms.tidyverse.org/
# Importing other types of data:
#     feather, for sharing with Python and other languages. https://github.com/wesm/feather
#     haven, for SPSS, SAS and Stata files. https://haven.tidyverse.org/
#     httr, for web apis. https://httr.r-lib.org/
#     jsonlite for JSON. https://arxiv.org/abs/1403.2805
#     readxl, for .xls and .xlsx files. https://readxl.tidyverse.org/
#     rvest, for web scraping. https://rvest.tidyverse.org/
#     xml2, for XML. https://xml2.r-lib.org/
# Modelling
#     modelr, for modelling within a pipeline. https://modelr.tidyverse.org/
#     broom, for turning models into tidy data. https://broom.tidymodels.org/

# Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors



#setting viridis theme for colors
scale_colour_continuous <- scale_colour_viridis_c
scale_colour_discrete   <- scale_colour_viridis_d
scale_colour_binned     <- scale_colour_viridis_b
#setting viridis theme for fill
scale_fill_continuous <- scale_fill_viridis_c
scale_fill_discrete   <- scale_fill_viridis_d
scale_fill_binned     <- scale_fill_viridis_b