import os
from conga.tcrdist.make_10x_clones_file import make_10x_clones_file_batch
from conga.preprocess import make_tcrdist_kernel_pcs_file_from_clones_file

def process_tcr(tcr_meta, results_dir="results", perform_kpca="auto"):
    
    """
    Processes TCR meta information from a specified CSV file, creates a merged clones file,
    and optionally performs kernel PCA (kPCA) on that file based on the user's choice.

    The script takes in a tcr_meta.csv file, which points to the filtered contig annotations
    files and assigns each a batch_id, resulting in a merged_clones.tsv file. If chosen, 
    it then performs PCA on the merged_clones.tsv file.

    Parameters:
        tcr_meta (str): The file path to the TCR meta information CSV file. This file 
                        contains the necessary data for TCR analysis.
        perform_kpca (str): A string parameter to control the execution of kPCA. Accepts
                            'yes', 'no', and 'auto'. 'yes' executes the kPCA step, 'no' 
                            skips kPCA, and 'auto' decides based on the number of rows in 
                            the TSV file. If the number of clones is 50,000 or less, kPCA
                            will be performed. If the number is greater, 'auto' will skip 
                            kPCA.

    Behavior:
        1. Directory Creation: Determines the directory of the provided tcr_meta file and 
           creates a new directory named 'results' in the same location, if it does not 
           already exist.
        2. File Processing: Calls make_10x_clones_file_batch to process the TCR meta 
           information and generate merged_clones.tsv.
        3. kPCA Step: Based on the perform_kpca parameter, it either runs, skips, or 
           auto-determines the execution of the kPCA step. The 'auto' option runs kPCA if 
           the number of clones is less than 50,000.

    Usage Example:
        # Command line execution
        python make_conga_clone.py path/to/tcr_meta.csv --perform-kpca yes

    Notes:
        - Intended to be used as the main entry point for a script processing TCR meta 
          information.
        - Assumes the presence of conga.tcrdist.make_10x_clones_file and 
          conga.preprocess modules.
        - The kPCA step execution is controlled by the --perform-kpca command line 
          argument.
    """

    # Extract directory from tcr_meta path
    dir_path = os.path.dirname(os.path.abspath(tcr_meta))
    
    # Change working directory to tcr_meta path
    orig_wd = os.getcwd()
    os.chdir(dir_path)

    # Create 'results' directory in the same location as tcr_meta, if it doesn't exist
    results_dir = os.path.join(dir_path, results_dir)
    if not os.path.exists(results_dir):
        os.makedirs(results_dir)

    # Define the path for merged_clones.tsv within the results directory
    # Make merged_clones_path a global variable so it will be accessible to R later
    # global merged_clones_path
    merged_clones_path = os.path.join(results_dir, 'merged_clones.tsv')

    # Run make conga clone: Takes in tcr_meta.csv, assigns batch_id to filtered contig annotations,
    # resulting in merged_clones.tsv.
    make_10x_clones_file_batch(tcr_meta, 'human', merged_clones_path)

    # Determine whether to run kPCA based on command line option
    if perform_kpca == 'yes':
        make_tcrdist_kernel_pcs_file_from_clones_file(merged_clones_path, 'human')
    elif perform_kpca == 'auto':
        # Auto-determine based on the number of rows in the TSV file
        with open(merged_clones_path, 'r') as f:
            num_rows = sum(1 for _ in f)
        if num_rows < 50000:
            make_tcrdist_kernel_pcs_file_from_clones_file(merged_clones_path, 'human')
    # 'no' option implies skipping the kPCA step
    
    # return to original wd
    os.chdir(orig_wd)
    
    return merged_clones_path
