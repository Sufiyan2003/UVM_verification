import yaml
import sys


# file where all the test cases are created
file_name = "./test_db.yaml"

def parse_yaml(test_name):
    with open(file_name, 'r') as f:
        data = yaml.safe_load(f)

    if test_name not in data:
        print(f"Error: {test_name} not found in YAML", file=sys.stderr)
        sys.exit(1)

    plusargs = data[test_name].get("plusargs", [])
    return " ".join(plusargs)

if __name__ == "__main__":
    test_name = sys.argv[1]
    print(parse_yaml(test_name))