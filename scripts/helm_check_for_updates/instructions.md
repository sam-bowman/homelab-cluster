# Instructions for helm-check-for-updates

Run the script from ../scripts

The script functions as follows:

1. Scan all files recursively in ../../argocd
2. Check if file is kind: Application
    * This will ignore all files with multiple yaml definitons (separated by --- usually)
    * It will check for the 'kind' key, and skip if missing (e.g. for values files)
    * Adds the file to a list if it meets all criteria
3. Gets configuration from file - yaml to object
4. Checks if app has a list of sources defined, skips if not
5. Checks if any of the sources are helm chart definitions, skips if missing
6. Runs the helm repo add command on the local system
7. Runs the helm search repo command for the added repo on the local system
8. Find the relevant helm chart from the added repo
9. Gets the latest chart version from this and compares to what is currently in the app definition source
10. Updates the sources if there's a newer version & the user wants to.
