"""Store the replacement provider key locally without echoing it or using shell history."""
import getpass
import os
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[1]
target = root / 'functions/.secret.local'
if subprocess.run(['git', 'check-ignore', '-q', str(target)], cwd=root).returncode:
    raise SystemExit('Stopped: secret file is not ignored by Git.')
key = getpass.getpass('Paste your NEW Gemini API key (input is hidden), then press Enter: ').strip()
if not key or any(c.isspace() for c in key):
    raise SystemExit('Key must be nonempty and contain no whitespace.')
lines = target.read_text().splitlines() if target.exists() else []
lines = [line for line in lines if not line.startswith('GOOGLE_GENAI_API_KEY=')]
lines.append('GOOGLE_GENAI_API_KEY=' + key)
fd = os.open(target, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
os.fchmod(fd, 0o600)
with os.fdopen(fd, 'w') as handle:
    handle.write('\n'.join(lines) + '\n')
print('Saved securely to ignored functions/.secret.local. Reply "done" in chat; do not send the key.')
