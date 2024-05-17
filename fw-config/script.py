import json
import requests
import os


# FW Secrets
fw_key = os.getenv("FW_KEY")
fw_secret = os.getenv("FW_SECRET")
fw_base_url = os.getenv("FW_FQDN")
# GH Secrets
gh_url_vars = os.getenv("GH_VAR_URL")
gh_token = os.getenv("GH_TOKEN")


# LOAD OVERRIDES AND ALIAS FROM FILES
with open('hostOverride.json') as f:
  host_overrides = json.loads(f.read())
with open('hostAliases.json') as f:
  host_aliases = json.loads(f.read())


# CREATE GITHUB SESSION AND GET EXISTING VARS
gh_session = requests.Session()
gh_session.headers = {
  "Accept":"application/vnd.github+json",
  "Authorization":f"Bearer {gh_token}",
  "X-GitHub-Api-Version":"2022-11-28"
}
gh_vars = json.loads(gh_session.get(gh_url_vars).text)['variables']

# OVERRIDES
for host_override in host_overrides:
  # Check if UUID in github
  gh_uuid_var_name = f"FW_HOST_OVERRIDE_UUID_{host_override['description']}"
  found_in_gh = False
  needs_updating = False
  for var in gh_vars:
    if var['name'] == gh_uuid_var_name:
      print(f"{gh_uuid_var_name} already in repo variables")
      found_in_gh = True
      # Find uuid in FW

      # Check for differences

  # Update on FW if differences found

  # Create on FW and GH if not found anywhere
  if not found_in_gh and not needs_updating:
    # Create override in FW

    # Create secret in github
    print(f"{gh_uuid_var_name} not in repo variables, creating")
    data = json.dumps({"name":gh_uuid_var_name, "value":"1234"})
    gh_session.post(gh_url_vars, data=data)

# ALIASES
for host_alias in host_aliases:
  # Check if UUID in github
  gh_uuid_var_name = f"FW_HOST_OVERRIDE_UUID_{host_alias['description']}"
  found_in_gh = False
  needs_updating = False
  for var in gh_vars:
    if var['name'] == gh_uuid_var_name:
      print(f"{gh_uuid_var_name} already in repo variables")
      found_in_gh = True
      # Find uuid in FW

      # Check for differences

  # Update on FW if differences found

  # Create on FW and GH if not found anywhere
  if not found_in_gh and not needs_updating:
    # Create alias in FW

    # Create secret in github
    print(f"{gh_uuid_var_name} not in repo variables, creating")
    data = json.dumps({"name":gh_uuid_var_name, "value":"1234"})
    gh_session.post(gh_url_vars, data=data)