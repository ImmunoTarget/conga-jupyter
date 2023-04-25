FROM jupyter/datascience-notebook:2022-11-28

RUN git clone https://github.com/phbradley/conga.git

WORKDIR conga/tcrdist_cpp
RUN make

WORKDIR ..
RUN pip install -e .

RUN pip install anndata2ri

RUN R -e "install.packages('Seurat',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('reticulate',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('patchwork',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tidyverse',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('BiocManager',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "BiocManager::install('SingleCellExperiment')"

RUN wget https://www.dropbox.com/s/r7rpsftbtxl89y5/conga_example_datasets_v1.zip
RUN unzip conga_example_datasets_v1.zip
