#!/usr/bin/env python3
"""Create and boot a predictable iOS 18.5 simulator for the Xcode 16.4 CI jobs."""
import json
import os
import subprocess
import sys


def simctl_list(kind):
    return json.loads(subprocess.check_output(["xcrun", "simctl", "list", kind, "--json"]))[kind]


def prepare(device_name):
    runtimes = simctl_list("runtimes")
    runtime = next((r for r in runtimes if r.get("isAvailable") and r.get("version") == "18.5"
                    and ".iOS-" in r["identifier"]), None)
    if runtime is None:
        # Hosted images do not always include the same simulator runtimes.
        subprocess.run(["xcodebuild", "-downloadPlatform", "iOS", "-buildVersion", "18.5"], check=True)
        runtime = next((r for r in simctl_list("runtimes") if r.get("isAvailable")
                        and r.get("version") == "18.5" and ".iOS-" in r["identifier"]), None)
    if runtime is None:
        raise RuntimeError("iOS 18.5 simulator runtime is unavailable after installation")
    device_type = next((d for d in simctl_list("devicetypes") if d["name"] == device_name), None)
    if device_type is None:
        raise RuntimeError(f"Unknown simulator device type: {device_name}")
    identifier = subprocess.check_output([
        "xcrun", "simctl", "create", f"Taap CI {device_name}",
        device_type["identifier"], runtime["identifier"]
    ], text=True).strip()
    subprocess.run(["xcrun", "simctl", "boot", identifier], check=True)
    subprocess.run(["xcrun", "simctl", "bootstatus", identifier, "-b"], check=True)
    if env_file := os.environ.get("GITHUB_ENV"):
        with open(env_file, "a", encoding="utf-8") as output:
            output.write(f"TAAP_SIMULATOR_UDID={identifier}\n")
    print(f"Ready: {device_name} on iOS 18.5 ({identifier})")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: prepare_simulator.py 'iPhone 16 Pro'")
    prepare(sys.argv[1])
