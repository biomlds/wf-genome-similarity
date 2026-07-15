"""Create genome similarity report."""
import pandas as pd

from dominate.tags import p
from ezcharts.components.reports import labs
from ezcharts.layout.snippets.table import DataTable

from .util import get_named_logger, wf_parser  # noqa: ABS101


def main(args):
    """Run the entry point."""
    logger = get_named_logger("Report")
    logger.info("Creating genome similarity report.")

    # Create report
    report = labs.LabsReport(
        "Genome Similarity Report", "wf-genome-similarity",
        args.params, args.versions, args.wf_version)

    # Section 1: Jaccard Scores
    with report.add_section("Jaccard Scores", "Jaccard Scores"):
        p("Similarity scores between query samples and reference databases.")
        df_jaccard = pd.read_csv(args.jaccard_scores, sep='\t')
        DataTable.from_pandas(df_jaccard)

    # Section 2: Pairwise Jaccard Scores
    with report.add_section("Pairwise Jaccard Scores", "Pairwise Scores"):
        p("Pairwise similarity scores between all samples.")
        df_pairwise = pd.read_csv(args.jaccard_pairwise, sep='\t')
        DataTable.from_pandas(df_pairwise)

    # Write report
    report.write(args.report)
    logger.info(f"Report written to {args.report}.")


def argparser():
    """Argument parser for entrypoint."""
    parser = wf_parser("genome_similarity_report")
    parser.add_argument("report", help="Report output file")
    parser.add_argument(
        "--jaccard_scores", required=True,
        help="Path to jaccard_score.tsv")
    parser.add_argument(
        "--jaccard_pairwise", required=True,
        help="Path to jaccard_score_pairwise.tsv")
    parser.add_argument(
        "--params", required=True,
        help="A JSON file containing the workflow parameter key/values")
    parser.add_argument(
        "--versions", required=True,
        help="directory containing CSVs containing name,version.")
    parser.add_argument(
        "--wf_version", default='unknown',
        help="version of the executed workflow")
    return parser
