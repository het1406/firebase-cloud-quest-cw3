"""Run real Android integration tests and capture adb screenshots at test markers."""
import subprocess
import re
import os
import shutil
from pathlib import Path
root = Path(__file__).resolve().parents[1]
flutter = os.environ.get('FLUTTER_BIN') or shutil.which('flutter') or str(Path.home() / 'develop/flutter/bin/flutter')
adb = os.environ.get('ADB_BIN') or shutil.which('adb') or str(Path.home() / 'Library/Android/sdk/platform-tools/adb')
device = os.environ.get('ANDROID_DEVICE', 'emulator-5554')
live = os.environ.get('LIVE_COACH') == 'true'
logname = 'android-live-journey.txt' if live else 'android-journey.txt'
with (root / 'evidence' / logname).open('w') as log:
    proc = subprocess.Popen([flutter, 'test', 'integration_test/journey_test.dart', '-d', device, '--reporter', 'expanded', *(['--dart-define=LIVE_COACH=true'] if live else [])], cwd=root, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    for line in proc.stdout:
        log.write(line)
        log.flush()
        print(line, end='', flush=True)
        marker = re.search(r'EVIDENCE: ([a-z0-9-]+)', line)
        if marker:
            with (root / f'evidence/{marker[1]}.png').open('wb') as png:
                subprocess.run([adb, '-s', device, 'exec-out', 'screencap', '-p'], stdout=png, check=True)
    raise SystemExit(proc.wait())
