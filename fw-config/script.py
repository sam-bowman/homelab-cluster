import json
import requests
import os

# FUNCTION TO PROCESS GH SECRETS & FW CONFIG
def process_objects(uuid_type, objects, gh_vars, getUrl, addUrl, setUrl):
  for var in gh_vars:
    # Check all secrets for current type
    if uuid_type in var['name']:
      for object in objects:
        # Get value for current object from gh secrets
        desired_name = f"FW_HOST_{uuid_type}_UUID_{object['description']}"
        if var['name'] == desired_name:
          uuid = var['value']
          fw_object = json.loads(fw_session.get(f"{getUrl}/{uuid}").text)
          if fw_object != []:
            if uuid_type == "OVERRIDE":
              fw_object = fw_object['host']
              en = fw_object['enabled'] == object['enabled']
              hn = fw_object['hostname'] == object['hostname']
              do = fw_object['domain'] == object['domain']
              se = fw_object['server'] == object['server']
              de = fw_object['description'] == object['description']
              if not (en and hn and do and se and de):
                # Update FW object
                print("TEMP")
            elif uuid_type == "ALIAS":
              fw_object = fw_object['alias']
              en = fw_object['enabled'] == object['enabled']
              hn = fw_object['hostname'] == object['hostname']
              do = fw_object['domain'] == object['domain']
              de = fw_object['description'] == object['description']
              if not (en and hn and do and de):
                # Update FW object
                print("TEMP")


if __name__ == "__main__":
  # LOAD OVERRIDES AND ALIAS FROM FILES
  with open('hostOverride.json') as f:
    host_overrides = json.loads(f.read())
  with open('hostAliases.json') as f:
    host_aliases = json.loads(f.read())

  # SET GH CONFIG
  gh_url_vars = os.getenv("GH_VAR_URL")
  gh_token = os.getenv("GH_TOKEN")
  # CREATE GITHUB SESSION
  gh_session = requests.Session()
  gh_session.headers = {
    "Accept":"application/vnd.github+json",
    "Authorization":f"Bearer {gh_token}",
    "X-GitHub-Api-Version":"2022-11-28"
  }
  # GET GITHUB EXISTING VARS
  gh_vars = json.loads(gh_session.get(gh_url_vars).text)['variables']

  # SET FW CONFIG
  fw_key = os.getenv("FW_KEY")
  fw_secret = os.getenv("FW_SECRET")
  fw_fqdn = os.getenv("FW_FQDN")
  # FW URLS
  fw_api = f"https://{fw_fqdn}/api"
  unbound = f"{fw_api}/unbound/settings"
  searchHostOverride = f"{unbound}/searchHostOverride"
  getHostOverride = f"{unbound}/getHostOverride"
  addHostOverride = f"{unbound}/addHostOverride"
  setHostOverride = f"{unbound}/setHostOverride"
  searchHostAlias = f"{unbound}/searchHostAlias"
  getHostAlias = f"{unbound}/getHostAlias"
  addHostAlias = f"{unbound}/addHostAlias"
  setHostAlias = f"{unbound}/setHostAlias"
  # CREATE FW SESSION
  fw_session = requests.Session()
  fw_session.headers = {
    "Accept":"application/json"
  }
  fw_session.auth = (fw_key, fw_secret)
  # GET FW EXISTING OVERRIDES AND ALIASES
  fw_overrides = json.loads(fw_session.get(searchHostOverride).text)['rows']
  fw_aliases = json.loads(fw_session.get(searchHostAlias).text)['rows']

  process_objects("OVERRIDE", host_overrides, gh_vars, getHostOverride, addHostOverride, setHostOverride)
  process_objects("ALIAS", host_aliases, gh_vars, getHostAlias, addHostAlias, setHostAlias)