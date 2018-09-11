# -*- coding: utf-8 -*-
from pathlib import Path

import click
from cookiecutter.exceptions import FailedHookException
from cookiecutter.main import cookiecutter

from . import __version__


@click.group(context_settings=dict(help_option_names=["-h", "--help"]))
@click.version_option(__version__, "-v", "--version")
def main():
    pass


@main.command(short_help="Initialise an evalutils project.")
@click.argument("challenge_name")
@click.option(
    "--kind",
    type=click.Choice(["Classification", "Segmentation", "Detection"]),
    prompt="What kind of challenge is this? [Classification|Segmentation|Detection]",
)
def init(challenge_name, kind):
    template_dir = Path(__file__).parent / "template"

    try:
        cookiecutter(
            template=str(template_dir.absolute()),
            no_input=True,
            extra_context={
                "challenge_name": challenge_name,
                "evalutils_name": __name__.split(".")[0],
                "evalutils_version": __version__,
                "challenge_kind": kind,
            },
        )
        click.echo(f"Created project {challenge_name}")
    except FailedHookException:
        exit(1)
