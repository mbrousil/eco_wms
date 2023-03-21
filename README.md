# Files related to *Improving ecological data science with workflow management software*

This repository contains files related to the publication, *Improving ecological data science with workflow management software* (Brousil et al. 2023).

The repository contains files related to two items:

1.  Building Figure 2, a time series of publications referencing "workflow management software" or "data pipeline" within Web of Science. (`abstract_figure/` subdirectory)
2.  An example of a small workflow written both as a [*targets*](https://books.ropensci.org/targets/) workflow and a traditional single-script R workflow (`example_workflow/` subdirectory)

### `abstract_figure/` subdirectory

Running the `scripts/evidence_synthesis_wms.R` file in this subdirectory should execute the entire process of downloading the [short dataset](https://doi.org/10.6084/m9.figshare.22307494.v1) needed to generate the figure and then plotting it and saving it as a PNG file in `figures/`.

### `example_workflow` subdirectory

Datasets provided in `data/` are simulated and created in the script `setup_data.R`. The file `non_targets_script.R` is a self-contained short workflow. It provides identical results as the *targets* workflow, which can be initiated using the `run.R` script. Steps ("targets") for this workflow version are outlined in `_targets.R`.
