import yaml
import sys


# contains yaml for all verif env
tests_summary_path = "./cfg/test_paths.yaml"
test_db_path = "./test_db.yaml"

def generate_testdb():
    write_to_db = {}
    with open(tests_summary_path, 'r') as f:
        all_yamls = yaml.safe_load(f)
        # all yamls contain all the file paths that we need to compile

    # create test_db file and we will save all the tests in it
    with open(test_db_path, "w") as f:
        for test_files in all_yamls["all_test_specs"]:
            # read each yaml file
            with open(test_files, "r") as nf:
                tests = yaml.safe_load(nf)
                yaml.dump(tests, f)
    return 0


def parse_yaml(test_name):
    with open(file_name, 'r') as f:
        data = yaml.safe_load(f)

    if test_name not in data:
        print(f"Error: {test_name} not found in YAML", file=sys.stderr)
        sys.exit(1)

    plusargs = data[test_name].get("plusargs", [])
    return " ".join(plusargs)

if __name__ == "__main__":
    generate_testdb()
    # test_name = sys.argv[1]
    # print(parse_yaml(test_name))

