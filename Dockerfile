FROM jupyter/datascience-notebook:2022-11-28

RUN git clone https://github.com/phbradley/conga.git

WORKDIR conga/tcrdist_cpp
RUN make

WORKDIR ..
RUN pip install -e .

RUN pip install anndata2ri

# Install Remotes
RUN R -e "install.packages('remotes', dependencies=TRUE, repos='http://cran.rstudio.com/')"

# Install Seurat 4.4.0
# RUN R -e "options(repos = remotes::install_version('Seurat', version='4.4.0'. repos='http://cran.rstudio.com/')"
# RUN R -e "install.packages('hdf5r', dependencies=TRUE, repos='http://cran.rstudio.com/')"
# RUN R -e "install.packages('reticulate',dependencies=TRUE, repos='http://cran.rstudio.com/')"
# RUN R -e "install.packages('patchwork',dependencies=TRUE, repos='http://cran.rstudio.com/')"
# RUN R -e "install.packages('tidyverse',dependencies=TRUE, repos='http://cran.rstudio.com/')"

# Bioconductor Packages
# RUN R -e "install.packages('BiocManager', dependencies=TRUE, repos='http://cran.rstudio.com/')"
# RUN R -e "BiocManager::install('SingleCellExperiment')"
# RUN R -e "BiocManager::install('DropletUtils')"

# Sample data
RUN wget https://www.dropbox.com/s/r7rpsftbtxl89y5/conga_example_datasets_v1.zip
RUN unzip conga_example_datasets_v1.zip

# Copy data for binger
COPY my_scripts my_scripts

# imagemagick
USER root
RUN apt-get update && apt-get install -y imagemagick
USER jovyan