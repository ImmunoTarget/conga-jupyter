library(purrr)
quietly(library(Seurat))
quietly(library(dplyr))
library(DropletUtils)
library(stringr)
library(tidyr)
library(reticulate)
use_python("/usr/bin/python3", required = TRUE)

# Function: parse_conga_clones_for_seurat
parse_conga_clones_for_seurat <- function(clone_file) {
  map_file <- paste0(clone_file, ".barcode_mapping.tsv")
  map_file_df <- read.delim(map_file, stringsAsFactors = FALSE) 
  clone_file_df <- read.delim(clone_file, stringsAsFactors = FALSE) 

  melt_barcode <- function(x){
    df <- data.frame(x$clone_id,
                     str_split(x$barcodes, pattern = ",", simplify = TRUE),
                     stringsAsFactors = FALSE)
    colnames(df)[1] <- "clone_id"
    df <- df %>% 
      gather(key = "col", value = "barcode", 2:ncol(df)) %>% 
      select(-col) %>% 
      filter(barcode != "")
    
    return(df)
  }
  
  map_file_df <- melt_barcode(map_file_df)
  clone_book <- left_join(map_file_df, clone_file_df, by = "clone_id")
  clone_book$suffix <- str_split(clone_book$barcode, '-', simplify = TRUE)[,2]
  
  return(clone_book)
}

# Function: process_seurat_data
process_seurat_data <- function(clones_file, h5_files, ig_tcr_file = "combo_10X_IgTcr.tsv") {
    clones_dir <- dirname(clones_file)
  
    if (!file.exists(ig_tcr_file)) {
        ig_tcr_file <- "/home/rstudio/scripts/R/combo_10X_IgTcr.tsv"
    }
  
    IgTcr <- read.delim(ig_tcr_file)
    
    seurat_objects <- list()
    
    for (i in 1:length(h5_files)) {
        cmat <- Read10X_h5(h5_files[i])
        if(i > 1) {
            colnames(cmat) <- gsub('-1', paste0('-', i), colnames(cmat))
        }
        pre_obj <- CreateSeuratObject(cmat, min.cells = 5, min.features = 300)
        seurat_objects[[i]] <- pre_obj
    }
    
    obj <- Reduce(function(x, y) merge(x, y), seurat_objects)

    obj[["percent.mt"]] <- PercentageFeatureSet(obj, pattern = "^MT-")
    obj <- subset(obj, subset = nFeature_RNA < 3000 & percent.mt < 10)
    
    obj <- NormalizeData(object = obj) %>% 
        FindVariableFeatures(.) %>% 
        ScaleData(.) %>% 
        RunPCA(., features = VariableFeatures(obj)) %>% 
        FindNeighbors(.) %>% 
        FindClusters(.) %>% 
        RunUMAP(., dims = 1:50)
  
    DimPlot(obj)
  
    in_clones <- parse_conga_clones_for_seurat(clones_file)
    rownames(in_clones) <- in_clones$barcode
    obj <- AddMetaData(obj, in_clones)
  
    counts_path <- file.path(clones_dir, 'merged_counts_matrix.h5')
    if (file.exists(counts_path)) {
        warning("Counts file already exists. Move or delete it to run this script.")
    } else {
        write10xCounts(x = obj@assays$RNA@counts, path = counts_path)
    }
    saveRDS(obj, file.path(clones_dir, 'merged_seurat.rds'))
  
    return(counts_path)
}