#!/bin/bash
set -xe

pip install -U Jinja2 PyYAML
# Needed to install jinja2 and PyYAML requirements to run the templating script.

python -m config_templates.chartmap