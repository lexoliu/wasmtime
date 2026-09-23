import hashlib
import json
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parent
source = Path(sys.argv[1]).resolve()
original = source.read_bytes()
assembly = original.decode().replace('.section .text.helios_x86_exceptions, "ax"', '.text', 1)
output = root / 'entry.S'
output.write_text('.intel_syntax noprefix\n' + assembly)
binary = root / 'irq-probe'
subprocess.run(['clang', '-arch', 'x86_64', '-Wl,-no_fixup_chains', str(root / 'probe.S'), str(output), '-o', str(binary)], check=True, cwd=root)
result = subprocess.run([str(binary)], cwd=root, check=False)
report = {'source': str(source), 'sha256': hashlib.sha256(original).hexdigest(), 'exit_code': result.returncode, 'preserved_xmm0': result.returncode == 0}
(root / 'result.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report))
raise SystemExit(result.returncode)
