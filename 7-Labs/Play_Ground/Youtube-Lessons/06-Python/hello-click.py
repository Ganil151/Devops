import click


# Define a Click command-line interface
# that takes a phrase as input and tokenizes it into words.
# Each word should be printed on a new line.
@click.command()
@click.option("--phrase", prompt="Enter a phrase", help="")
def tokenize(phrase):
    """token phrase"""
    click.echo(f"tokenized phrase: {phrase.split()}")

if __name__ == "__main__":
    tokenize()