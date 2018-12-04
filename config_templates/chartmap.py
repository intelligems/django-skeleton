import os
import yaml
from jinja2 import Environment, FileSystemLoader


PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEMPLATE_DIR = os.path.join(PROJECT_DIR, 'config_templates')
TEMPLATE_FILES = ['{{ project_name }}.yml.tpl', '.drone.yml.tpl']


def load_config_data(config_source):
    with open(config_source, 'r') as config_file:
        return yaml.load(config_file.read())


def load_template(template_filename, template_folder):
    env = Environment(loader=FileSystemLoader(template_folder), trim_blocks=True, lstrip_blocks=True)
    return env.get_template(template_filename)


if __name__ == '__main__':
    config_data = load_config_data(os.path.join(TEMPLATE_DIR, 'config_source.yml'))
    for template_file in TEMPLATE_FILES:
        template = load_template(template_file, TEMPLATE_DIR)

        targetdir = PROJECT_DIR
        if template_file.startswith('{{ project_name }}'):
            targetdir = os.path.join(PROJECT_DIR, 'swarm')

        with open(os.path.join(targetdir, template_file.replace('.tpl', '')), 'w') as outfile:
            outfile.write(template.render(config_data))
