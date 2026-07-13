This workflow performs genome similarity analysis on compressed genome assemblies.

The workflow:

+ Accepts a directory containing `*.medaka.fasta.gz` genome assembly files
+ Preprocesses files by uncompressing assemblies only when needed (preserves existing `*.medaka.fasta` files)
+ Runs mentalist to compute pairwise Jaccard similarity scores
+ Outputs a `jaccard_score.csv` file with the similarity matrix
