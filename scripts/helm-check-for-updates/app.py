# Simple script to check all helm chart version in specified files, and update said  version if a new version
# has been released. 

import yaml
import subprocess
from pathlib import Path

def kind_application(file):
    print(f'DEBUG:      Checking file {file} to see if it is kind: Application')
    with open(file, 'r') as f:
        try:
            contents = yaml.safe_load(f)
        except:
            print(f'WARNING:    File {file} contains multiple yaml streams, skipping.')
            return False
    if contents != None:
        if 'kind' in contents:
            if contents['kind'] == 'Application':
                return True
    return False

def get_files_to_check(base_dir):
    app_files = []
    all_yamls = list(Path(base_dir).rglob("*.[yY][aA][mM][lL]"))
    for file in all_yamls:
        if kind_application(str(file)):
            app_files.append(str(file))
    return(app_files)

def get_app_configuration(file):
    with open(file, 'r') as f:
        return yaml.safe_load(f)

def get_app_sources(app_config):
    try:
        return app_config['spec']['sources']
    except:
        print('INFO:       No app sources found.')
        return None

def get_helm_chart_source(app_sources):
    source_index = 0
    for source in app_sources:
        if 'chart' in source:
            return source, source_index
        source_index += 1
    print(f'INFO:       No helm chart source found.')
    return None, None

def add_helm_repo(chart, repo_url):
    return subprocess.run(['helm','repo','add',chart,repo_url], 
                    stdout = subprocess.PIPE, 
                    stderr = subprocess.PIPE, 
                    universal_newlines = True).stdout

def search_helm_repo(chart):
    return subprocess.run(['helm','search','repo',chart,'--max-col-width','1000'], 
                            stdout = subprocess.PIPE, 
                            stderr = subprocess.PIPE, 
                            universal_newlines = True).stdout

def get_relevant_repo(repo_search, chart):
    repo_list = repo_search.splitlines()
    repo_list.pop(0)
    for repo in repo_list:
        name, chart_ver, app_ver, desc = repo.split(maxsplit=3)
        if name == f'{chart}/{chart}':
            return name, chart_ver, app_ver, desc
        
def update_available(current_version, chart_version):
    if current_version != chart_version:
        print(f'INFO:       New version of \'{chart}\' available')
        print(f'INFO:           Current Version:    {current_version}')
        print(f'INFO:           New Version:        {chart_ver}')
        return True
    else:
        print(f'INFO:       Chart \'{chart}\' is already up to date!')
        return False

def apply_change(app_config, source_index, file):
    apply_change = input(f'Apply new version to \'{file}\' ? [y/n]').lower()
    if apply_change == 'y' or apply_change == 'yes':
        app_config['spec']['sources'][source_index]['targetRevision'] = chart_ver
        with open(file, 'w') as w:
            yaml.dump(app_config, w)
        print(f'INFO:       Helm chart targetRevision updated for {app_config["spec"]["sources"][source_index]["chart"]} \n\n')
    else:
        print(f'INFO:       Not applying change \n\n')

if __name__ == "__main__":
    print('DEBUG:      Getting list of yaml files with \'app\' in the name (should be application definition files) \n\n')
    files_to_check = get_files_to_check('../argocd/')

    for file in files_to_check:

        print(f'\n\nDEBUG:      Getting app configuration for file {file}')
        app_config = get_app_configuration(file)

        app_name = app_config['metadata']['name']
        print(f'DEBUG:      Getting app sources for {app_name} in file {file}')
        app_sources = get_app_sources(app_config)
        if app_sources == None:
            print(f'Skipping {app_name} in file {file}')
            continue

        print(f'DEBUG:      Checking for helm chart configuration for app {app_name} in file {file}')
        helm_chart_source, source_index = get_helm_chart_source(app_sources)
        if helm_chart_source == None:
            print(f'Skipping {app_name} in file {file}')
            continue

        chart = helm_chart_source['chart']
        repo_url = helm_chart_source['repoURL']
        current_version = helm_chart_source['targetRevision']

        add_helm_repo(chart, repo_url)
        repo_search = search_helm_repo(chart)
        chart_name, chart_ver, app_ver, chart_desc = get_relevant_repo(repo_search, chart)

        if update_available(current_version, chart_ver):
            apply_change(app_config, source_index, file)