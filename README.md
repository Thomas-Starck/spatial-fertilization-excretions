# Spatialized Nutrients Fertilization and Excretions in France

- Code to estimate nutrient (N, P, K) fertilization and human excretions at fine resolution scale in France. Linked to a DOI on a Zenodo repository https://doi.org/10.5281/zenodo.14605711

- Supporting results presented in Chapter 6 of the thesis "Towards a circular management of nitrogen and phosphorus in human excreta: current state, global agricultural potential, and spatial constraint in France" (Starck 2024), https://hal.science/tel-04727806

- See results rendered with Github Pages as an interactive website on https://thomas-starck.github.io/spatial-fertilization-excretions/ 

- The full website is rendered in the "docs" folder. Some chosen figures are rendered in the "graph" folder.

- Two folders were not uploaded here, because the files they contain are too large (>100s MB). The "source" folder, containing the original datasets used to run the code, and the "output" folder, containing the results rendered once the code is executed. 

- If you are interested in the full results or in reproducing the results, go to the Zenodo repository where these 2 folders are stored: https://doi.org/10.5281/zenodo.14605243


# Prerequisites

- **R version**: 4.3.3.
- **RStudio version**: 2023.06.1+524.
- **Quarto version**: 1.6.40.


# To Reproduce Results

After downloading this repository:

## first add the large source folder needed to run the code

- go to the Zenodo repository (https://doi.org/10.5281/zenodo.14605243) containing the large "source" folder, which could note be uploaded to Github because of the large files it contains
- download the "source" folder (~35-40 GB), and put it in this project root directory


## then remove the files produced with the code

- graph (contains graphs produced with the code)
- docs (contains the html pages for website)
- renv/library (should be absent at first download; contains packages, that will be restored with renv::restore() using renv.lock)
- output (should be absent at first download; contains rendered result files once the code has been executed)


## finally run the code 

- open potential-human-excretions-fertilization.Rproj in Rstudio
- in the console, run renv::restore() (to restore the project libraries using the renv package (version 1.0.11.))
- in the terminal, run quarto render (to run the full project and render the results)