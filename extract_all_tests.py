import yaml

file_name = "ci_test_spec.yaml"

def parse_yaml();

	with open(file_name, 'r') as f:
		data = yaml.load(f, Loader=yaml.SafeLoader)
		
	print data
	
	return 0


if __name__ == "__main__":
	print("Beginning parsing test spec yaml")
	parse_yaml()

