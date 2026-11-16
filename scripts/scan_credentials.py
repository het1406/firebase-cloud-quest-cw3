"""Scan every reachable Git blob and supplied ZIP for secret patterns and local key matches.
Public Firebase client configuration API keys are not server credentials.
Only file/object identifiers are emitted, never matched values.
"""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import zipfile
root = Path(__file__).resolve().parents[1]
secret_path = root / 'functions/.secret.local'
known = []
if secret_path.exists():
    for line in secret_path.read_text().splitlines():
        if line.startswith('GOOGLE_GENAI_API_KEY=') and line.partition('=')[2].strip():
            known.append(line.partition('=')[2].strip().encode())
patterns = [rb'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----', rb'gh[pousr]_[A-Za-z0-9]{25,}', rb'github_pat_[A-Za-z0-9_]{30,}', rb'ya29\.[A-Za-z0-9_-]{25,}', rb'AQ\.[A-Za-z0-9_-]{40,}', rb'"refresh_token"\s*:\s*"[^"\s]{20,}"']
findings = []
def check(data, identifier):
    if any(value in data for value in known) or any(re.search(pattern, data) for pattern in patterns):
        findings.append(identifier)
objects = subprocess.check_output(['git','rev-list','--objects','--all'],cwd=root,text=True).splitlines()
proc = subprocess.Popen(['git','cat-file','--batch'],cwd=root,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
blobs = 0
for row in objects:
    oid, _, name = row.partition(' ')
    proc.stdin.write((oid+'\n').encode()); proc.stdin.flush()
    header = proc.stdout.readline().decode().strip().split()
    size = int(header[2]); data = proc.stdout.read(size); proc.stdout.read(1)
    if header[1] == 'blob':
        blobs += 1; check(data, 'git:'+oid+':'+name)
proc.stdin.close(); proc.wait()
archives=[]
for arg in sys.argv[1:]:
    archive=Path(arg)
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        for name in z.namelist():
            if any(part in name for part in ['/node_modules/', '/.git/', '/.dart_tool/', '/.kotlin/', '/build/']) or name.endswith('/.secret.local'):
                findings.append('forbidden-archive-path:'+name)
            check(z.read(name),'zip:'+name)
        archives.append({'path':archive.name,'files':len(z.namelist()),'sha256':hashlib.sha256(archive.read_bytes()).hexdigest()})
result={'gitHead':subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),'passed':not findings,'gitBlobsScanned':blobs,'archives':archives,'findings':findings,'scope':'all reachable Git history blobs plus supplied ZIP contents; known local provider key exact-match and credential patterns; Firebase public client keys are not private server credentials'}
print(json.dumps(result,indent=2))
raise SystemExit(1 if findings else 0)
