#!/usr/bin/env python3
# Usage: ./apply.py PATH_TO_PATCH_DIR
# Only run from AOSP root directory
import json
import os
import subprocess
import sys

if len(sys.argv) != 2:
    print(f"Usage: {sys.argv[0]} PATH_TO_PATCH_DIR")
    exit(1)

patch_dir = sys.argv[1]
patch_index = os.path.join(patch_dir, "INDEX.json")
basedir = os.getcwd()

with open(patch_index, "r") as f:
    patches = json.load(f)

for path, patches_to_apply in patches.items():
    print(f"===== Patching {path} =====")

    os.chdir(path)

    for patch in patches_to_apply:
        print(f"-> Applying {patch}")
        patch_file_path = os.path.join(patch_dir, patch)

        result = subprocess.run(["git", "am", "-3", patch_file_path], capture_output=True, text=True)

        if "Patch failed at" in result.stdout:
            print("!!! Failed to apply! Aborting.")
            exit(1)
        elif "fatal" in result.stderr:
            print("!!! Failed to apply! Aborting. I got this from git:")
            print(result.stderr)
            exit(1)

    os.chdir(basedir)
    print()

print("Done!")
