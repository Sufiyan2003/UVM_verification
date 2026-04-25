import os
import sys

proj_dir = sys.argv[1]
test_name = sys.argv[2]

os.makedirs(proj_dir, exist_ok=True)

run_dir = os.path.join(proj_dir, test_name)
idx = 1

while os.path.exists(run_dir):
    run_dir = os.path.join(proj_dir, f"{test_name}.{idx}")
    idx += 1

print(run_dir)