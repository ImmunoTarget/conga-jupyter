# note the QC parameters here match those of the seurat object
# AF - had to modify paths because they pointed to his computer
python /home/jovyan/conga/scripts/run_conga.py \
--gex_data ./outs/merged_counts_matrix.h5 \
--gex_data_type 10x_h5 \
--clones_file ./outs/merged_clones.tsv \
--organism human \
--min_genes_per_cell 300 \
--max_genes_per_cell 3000 \
--max_percent_mito 0.1 \
--graph_vs_graph \
--outfile_prefix merged_conga_test