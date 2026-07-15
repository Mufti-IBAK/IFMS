import urllib.request
import json
import time

def check():
    req = urllib.request.Request('https://api.github.com/repos/Mufti-IBAK/IFMS/actions/runs')
    response = urllib.request.urlopen(req)
    data = json.loads(response.read())
    run = data['workflow_runs'][0]
    print(f"ID: {run['id']}, Status: {run['status']}, Conclusion: {run['conclusion']}")
    return run['status'], run['conclusion']

check()
