### 1. Preprocess medaka files

The workflow checks for `*.medaka.fasta.gz` files and uncompresses them only when the corresponding `*.medaka.fasta` file does not already exist. This ensures existing assembly files are never overwritten.

### 2. Run mentalist

The [mentalist](https://github.com/rrwick/mentalist) container is executed to compute pairwise Jaccard similarity scores between all genome assemblies in the input directory.

### 3. Output results

The workflow produces a `jaccard_score.csv` file containing the pairwise similarity matrix.
