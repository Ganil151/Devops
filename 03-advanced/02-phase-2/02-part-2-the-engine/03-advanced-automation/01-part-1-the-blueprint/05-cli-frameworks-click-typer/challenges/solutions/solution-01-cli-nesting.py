"""
Solution: Nested Cluster CLI
"""
import click

@click.group()
def cli():
    pass

@cli.group()
def cluster():
    """Commands to manage infrastructure clusters."""
    pass

@cluster.command()
@click.option("--engine", default="k8s", help="Orchestration engine.")
def create(engine):
    click.echo(f"Deploying {engine} cluster...")

@cluster.command()
@click.argument("name")
def delete(name):
    if click.confirm(f"Are you sure you want to delete {name}?"):
        click.echo(f"Deleting cluster {name}...")

if __name__ == "__main__":
    cli()
