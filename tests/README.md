# iOS Test Setup

## Recommended setup
Create and activate a virtual environment before installing deps:

```bash
cd /Users/tushar/code/hocuspocus-ios/tests/e2e
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt
```

## Faster runs + timeouts
- Default per-test timeout: 180s (override with `PYTEST_TIMEOUT=...`)
- Parallel (when safe): `pytest -n auto` (requires pytest-xdist)
- Appium command timeout: `APPIUM_CMD_TIMEOUT_MS=60000`
