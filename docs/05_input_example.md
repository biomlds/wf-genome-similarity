### Expected input structure

This workflow accepts a flat directory containing compressed genome assembly files.

```
─── input_folder
    ├── SAMPLE1.medaka.fasta.gz
    ├── SAMPLE2.medaka.fasta.gz
    ├── SAMPLE3.medaka.fasta.gz
    └── ...
```

### File naming convention

Files must follow the pattern: `SAMPLENAME.medaka.fasta.gz`

Where `SAMPLENAME` is the unique identifier for each sample.

### Preprocessing behavior

- If `SAMPLENAME.medaka.fasta.gz` exists and `SAMPLENAME.medaka.fasta` does **not** exist: the `.gz` file will be uncompressed
- If both `SAMPLENAME.medaka.fasta.gz` and `SAMPLENAME.medaka.fasta` exist: the existing `.fasta` file is preserved (no overwrite)
- If only `SAMPLENAME.medaka.fasta` exists: it will be used as-is
