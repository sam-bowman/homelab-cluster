""" Simple script to check all helm chart version in specified files,
and update said version if a new version has been released. """

import subprocess
from pathlib import Path
import yaml


def kind_application(resource_definition_file):
    """Takes a yaml file, and checks the k8s resource definiton type is application"""
    print(f'DEBUG:      Checking file {resource_definition_file} to see if it is kind: Application')
    with open(resource_definition_file, 'r', encoding='UTF-8') as f:
        try:
            contents = yaml.safe_load(f)
        except yaml.composer.ComposerError:
            print(f'WARNING:    File {resource_definition_file} contains \
multiple yaml streams, skipping.')
            return False
    if contents is not None:
        if 'kind' in contents:
            if contents['kind'] == 'Application':
                return True
    return False


def get_files_to_check(base_dir):
    """Takes a directory, and finds all yaml files inside that direcotry recursively"""
    app_files = []
    all_yamls = list(Path(base_dir).rglob("*.[yY][aA][mM][lL]"))
    for yaml_file in all_yamls:
        if kind_application(str(yaml_file)):
            app_files.append(str(yaml_file))
    return app_files


def get_app_configuration(app_config_file):
    """Takes a yaml configuration file, and returns the content"""
    with open(app_config_file, 'r', encoding='UTF-8') as f:
        return yaml.safe_load(f)


def get_app_sources(app_configuration):
    """Takes an arcd app configuration, and returns the sources defined within it"""
    try:
        return app_configuration['spec']['sources']
    except KeyError:
        print('INFO:       No app sources found.')
        return None


def get_helm_chart_source(sources):
    """Checks a list of sources for a helm chart source defintion"""
    idx = 0
    for source in sources:
        if 'chart' in source:
            return source, idx
        idx += 1
    print('INFO:       No helm chart source found.')
    return None, None


def add_helm_repo(chart, repo):
    """Runs the 'helm repo add' command to add the repo to the local system"""
    return subprocess.run(
            ['helm','repo','add',chart,repo],
            stdout = subprocess.PIPE,
            stderr = subprocess.PIPE,
            universal_newlines = True,
            check = True).stdout


def search_helm_repo(chart):
    """Run the 'helm search repo' command for the specified chart"""
    return subprocess.run(
            ['helm','search','repo',chart,'--max-col-width','1000'],
            stdout = subprocess.PIPE,
            stderr = subprocess.PIPE,
            universal_newlines = True,
            check = True).stdout


def get_relevant_repo(repo_search, chart):
    """From the results of the repo search, find the one for the specified chart"""
    repo_list = repo_search.splitlines()
    repo_list.pop(0)
    for repo in repo_list:
        name, c_ver, a_ver, desc = repo.split(maxsplit=3)
        if name == f'{chart}/{chart}':
            return name, c_ver, a_ver, desc
    return None


def update_available(chart, current, desired):
    """Compares the current version and the desired version of a chart"""
    if current != desired:
        print(f'INFO:       New version of \'{chart}\' available')
        print(f'INFO:           Current Version:    {current}')
        print(f'INFO:           New Version:        {desired}')
        return True
    print(f'INFO:       Chart \'{chart}\' is already up to date!')
    return False


def apply_change(config, idx, app_file, desired_version):
    """Updates the yaml file with the new helm chart version"""
    apply = input(f'Apply new version to \'{app_file}\' ? [y/n]').lower()
    if apply == 'y' or apply == 'yes':
        config['spec']['sources'][idx]['targetRevision'] = desired_version
        with open(app_file, 'w', encoding = 'UTF-8') as w:
            yaml.dump(config, w)
        print(f'INFO:       Helm chart targetRevision updated for \
{config["spec"]["sources"][idx]["chart"]} \n\n')
    else:
        print('INFO:       Not applying change \n\n')


if __name__ == "__main__":
    print('DEBUG:      Getting list of yaml files with \'app\' in the name (should be \
application definition files) \n\n')
    files_to_check = get_files_to_check('../argocd/')

    for file in files_to_check:

        print(f'\n\nDEBUG:      Getting app configuration for file {file}')
        app_config = get_app_configuration(file)

        app_name = app_config['metadata']['name']
        print(f'DEBUG:      Getting app sources for {app_name} in file {file}')
        app_sources = get_app_sources(app_config)
        if app_sources is None:
            print(f'Skipping {app_name} in file {file}')
            continue

        print(f'DEBUG:      Checking for helm chart configuration for app {app_name} in \
file {file}')
        helm_chart_source, source_index = get_helm_chart_source(app_sources)
        if helm_chart_source is None:
            print(f'Skipping {app_name} in file {file}')
            continue

        helm_chart = helm_chart_source['chart']
        repo_url = helm_chart_source['repoURL']
        current_version = helm_chart_source['targetRevision']

        add_helm_repo(helm_chart, repo_url)
        helm_repo_search = search_helm_repo(helm_chart)
        chart_name, chart_ver, app_ver, chart_desc = get_relevant_repo(
                                                        helm_repo_search,
                                                        helm_chart)

        if update_available(helm_chart, current_version, chart_ver):
            apply_change(app_config, source_index, file, chart_ver)
