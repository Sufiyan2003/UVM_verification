import yaml
import sys

file_name = "./test_db.yaml"

def extract_project_dirs(file_path):
    # placeholder for now
    return []


def extract_project_files(file_path):
    with open(file_path, 'r') as f:
        files = yaml.safe_load(f) or {}

    all_files = []

    vlog_dirs = files.get('vlog_dirs') or []
    vlog_files = files.get('vlog_files') or []

    # only extend if list is non-empty
    if vlog_dirs:
        all_files.extend(vlog_dirs)

    if vlog_files:
        all_files.extend(vlog_files)

    final_extracted_files = " ".join(all_files)

    # print(final_extracted_files)
    return final_extracted_files


if __name__ == "__main__":
    project_name = sys.argv[1]

    design_yaml_path = f"./design/{project_name}/{project_name}_rtl.yaml"
    verif_yaml_path = f"./verif/{project_name}/{project_name}_verif.yaml"

    design_files = extract_project_files(design_yaml_path)
    verif_files = extract_project_files(verif_yaml_path)

    all_files = " ".join(filter(None, [design_files, verif_files]))
    print(all_files)