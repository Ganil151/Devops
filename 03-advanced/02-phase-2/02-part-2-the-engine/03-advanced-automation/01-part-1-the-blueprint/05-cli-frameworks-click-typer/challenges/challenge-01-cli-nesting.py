"""
Challenge: Nested Cluster CLI
Scenario: You are building a tool called `k-ops`. 
It should have a subcommand `cluster` which itself has `create` and `delete`.

TODO: Implement the CLI using Click (or Typer).
1. Define a @click.group called `cli`.
2. Define a @cli.group called `cluster`.
3. Add a @cluster.command called `create` that takes an `--engine` option (default 'k8s').
4. Add a @cluster.command called `delete` that takes a required `--name` argument.
5. Print appropriate messages in each command.
"""
import click

# --- START YOUR CODE HERE ---

if __name__ == "__main__":
    # cli()
    pass
