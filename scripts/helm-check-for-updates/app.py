import yaml
import subprocess

files_to_check = [
    "../argocd/utility/app-cert-manager.yaml"
]

if __name__ == "__main__":
    for file in files_to_check:
        with open(file, 'r') as f:
            app = yaml.safe_load(f)
            source_counter = 0
            for source in app['spec']['sources']:
                if 'chart' in source:
                    chart = source['chart']
                    repoURL = source['repoURL']
                    targetRevision = source['targetRevision']
                    subprocess.run(['helm','repo','add',chart,repoURL], stdout = subprocess.DEVNULL)
                    repo_search = subprocess.run(['helm','search','repo',chart], 
                                                 stdout = subprocess.PIPE, 
                                                 stderr = subprocess.PIPE, 
                                                 universal_newlines = True)
                    repo_list = repo_search.stdout.splitlines()
                    repo_list.pop(0)
                    for repo in repo_list:
                        name, chart_ver, app_ver, desc = repo.split(maxsplit=3)
                        if name == f'{chart}/{chart}':
                            print(f'New version of \'{chart}\' available')
                            print(f'    Current Version:    {targetRevision}')
                            print(f'    New Version:        {chart_ver}')
                            apply_change = input(f'Apply new version to \'{file}\' ? [y/n]').lower()
                            if apply_change == 'y' or apply_change == 'yes':
                                app['spec']['sources'][source_counter]['targetRevision'] = chart_ver
                                with open(file, 'w') as w:
                                    yaml.dump(app, w)
                            else:
                                print(f'Not applying change \n\n')
                source_counter += 1