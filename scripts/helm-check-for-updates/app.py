# Simple script to check all helm chart version in specified files, and update said  version if a new version
# has been released. 

import yaml
import subprocess

# Find a way to pull this info automatically. All app definitions have app in the name, use that to find?
files_to_check = [
    "../argocd/utility/app-cert-manager.yaml",
    "../argocd/utility/app-csi-secrets-store.yaml",
    "../argocd/utility/app-github-arc.yaml",
    "../argocd/utility/app-consul.yaml",
    "../argocd/utility/app-vault.yaml",
    "../argocd/utility/app-homer.yaml",
    "../argocd/utility/app-kubernetes-dashboard.yaml",
    "../argocd/network/app-unifi.yaml",
    "../argocd/monitoring/app-grafana-alloy.yaml",
    "../argocd/monitoring/app-grafana.yaml",
    "../argocd/monitoring/app-loki.yaml",
    "../argocd/monitoring/app-promtail.yaml",
    "../argocd/monitoring/app-tempo.yaml",
    "../argocd/monitoring/app-victoria-metrics.yaml"
]

def get_app_configuration(file):
    with open(file, 'r') as f:
        return yaml.safe_load(f)

def get_app_sources(app_config):
    return app_config['spec']['sources']

def get_helm_chart_source(app_sources):
    source_index = 0
    for source in app_sources:
        if 'chart' in source:
            return source, source_index
        source_index += 1

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
        print(f'New version of \'{chart}\' available')
        print(f'    Current Version:    {current_version}')
        print(f'    New Version:        {chart_ver}')
        return True
    return False

def apply_change(app_config, source_index, file):
    apply_change = input(f'Apply new version to \'{file}\' ? [y/n]').lower()
    if apply_change == 'y' or apply_change == 'yes':
        app_config['spec']['sources'][source_index]['targetRevision'] = chart_ver
        with open(file, 'w') as w:
            yaml.dump(app_config, w)
    else:
        print(f'Not applying change \n\n')

if __name__ == "__main__":
    for file in files_to_check:

        app_config = get_app_configuration(file)
        app_sources = get_app_sources(app_config)
        helm_chart_source, source_index = get_helm_chart_source(app_sources)

        chart = helm_chart_source['chart']
        repo_url = helm_chart_source['repoURL']
        current_version = helm_chart_source['targetRevision']

        add_helm_repo(chart, repo_url)
        repo_search = search_helm_repo(chart)
        print(repo_search)
        print(f'\n\n')
        chart_name, chart_ver, app_ver, chart_desc = get_relevant_repo(repo_search, chart)

        if update_available(current_version, chart_ver):
            apply_change(app_config, source_index, file)