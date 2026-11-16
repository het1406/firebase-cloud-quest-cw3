"""Run real Android integration tests and capture adb screenshots at test markers."""
import subprocess
import re
import os
import shutil
from pathlib import Path
root = Path(__file__).resolve().parents[1]
flutter = os.environ.get('FLUTTER_BIN') or shutil.which('flutter') or '/Users/hetjani/develop/flutter/bin/flutter'
adb = os.environ.get('ADB_BIN') or shutil.which('adb') or str(Path.home() / 'Library/Android/sdk/platform-tools/adb')
with (root / 'evidence/android-journey.txt').open('w') as log:
    proc = subprocess.Popen([flutter, 'test', 'integration_test/journey_test.dart', '-d', 'emulator-5554', '--reporter', 'expanded'], cwd=root, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    for line in proc.stdout:
        log.write(line)
        log.flush()
        print(line, end='', flush=True)
        marker = re.search(r'EVIDENCE: ([a-z0-9-]+)', line)
        if marker:
            with (root / f'evidence/{marker[1]}.png').open('wb') as png:
                subprocess.run([adb, '-s', 'emulator-5554', 'exec-out', 'screencap', '-p'], stdout=png, check=True)
    raise SystemExit(proc.wait())
