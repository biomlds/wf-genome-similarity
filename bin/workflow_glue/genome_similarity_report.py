"""Create genome similarity report."""
import csv
import html

from .util import get_named_logger, wf_parser


def tsv_to_html_table(filepath):
    """Read a TSV file and return an HTML table string."""
    with open(filepath, 'r') as f:
        reader = csv.reader(f, delimiter='\t')
        rows = list(reader)

    if not rows:
        return "<p>No data available.</p>"

    headers = rows[0]
    data = rows[1:]

    table = '<table border="1" cellpadding="5" cellspacing="0">\n'
    table += '<thead><tr>'
    for h in headers:
        table += f'<th>{html.escape(h)}</th>'
    table += '</tr></thead>\n<tbody>\n'
    for row in data:
        table += '<tr>'
        for cell in row:
            table += f'<td>{html.escape(cell)}</td>'
        table += '</tr>\n'
    table += '</tbody></table>'
    return table


def main(args):
    """Run the entry point."""
    logger = get_named_logger("Report")
    logger.info("Creating genome similarity report.")

    jaccard_table = tsv_to_html_table(args.jaccard_scores)
    pairwise_table = tsv_to_html_table(args.jaccard_pairwise)

    html_content = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Genome Similarity Report</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; }}
        h1 {{ color: #333; }}
        h2 {{ color: #555; border-bottom: 1px solid #ccc; padding-bottom: 5px; }}
        table {{ border-collapse: collapse; width: 100%; margin: 10px 0; }}
        th {{ background-color: #f2f2f2; }}
        th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
        tr:nth-child(even) {{ background-color: #f9f9f9; }}
    </style>
</head>
<body>
    <h1>Genome Similarity Report</h1>

    <h2>Jaccard Scores</h2>
    <p>Similarity scores between query samples and reference databases.</p>
    {jaccard_table}

    # <h2>Pairwise Jaccard Scores</h2>
    # <p>Pairwise similarity scores between all samples.</p>
    # {pairwise_table}
</body>
</html>"""

    with open(args.report, 'w') as f:
        f.write(html_content)

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
    return parser
