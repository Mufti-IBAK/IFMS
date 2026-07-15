import urllib.request
import json

run_id = 29295133234
url = f"https://api.github.com/repos/Mufti-IBAK/IFMS/actions/runs/{run_id}/jobs"
req = urllib.request.Request(
    url, 
    headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
)

try:
    with urllib.request.urlopen(req) as response:
        if response.status == 200:
            data = json.loads(response.read().decode())
            jobs = data.get("jobs", [])
            for job in jobs:
                print(f"Job: {job['name']} - Status: {job['status']}, Conclusion: {job['conclusion']}")
                for step in job.get("steps", []):
                    print(f"  Step: {step['name']} - Status: {step['status']}, Conclusion: {step['conclusion']}")
        else:
            print(f"Failed to fetch jobs: {response.status}")
except Exception as e:
    print(f"Error checking jobs: {e}")
