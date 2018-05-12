. "$HKRAFT_SCRIPT_DIR/lib/beanstalk.sh"
. "$HKRAFT_SCRIPT_DIR/lib/aws_info.sh"

function assert_vpc_exists() {
  vpc_name="${1}"

  if [ $(list_vpcs | grep "^${vpc_name}$" -c) -eq 0 ]; then
    echo "Invalid VPC: ${vpc_name}"
    echo
    echo "Did you mean $(list_vpcs | paste -sd "/" -)?"
    exit 1
  fi
}

function assert_bucket_exists() {
  bucket_name="${1}"

  if [ $(list_buckets | grep "^${bucket_name}$" -c) -eq 0 ]; then
    echo "Bucket does not exist: ${bucket_name}"
    exit 1
  fi
}

function assert_matches() {
  name=${1}
  pattern=${2}
  msg=${3}
  
  if [[ ${name} != ${pattern} ]]; then
    echo "${msg}"
    echo
    echo "Use this format: ${pattern}"
    exit 1
  fi
}

function assert_valid_beanstalk_env_name() {
  app_name=${1}
  eb_env=${2}
  
  if [[ ${eb_env} != hkraft-${app_name}-* ]]; then
    echo "Invalid beanstalk environment name: ${eb_env}"
    echo
    echo "Use this format: hkraft-${app_name}-<environment>"
    exit 1
  fi
}

function assert_beanstalk_env_exits() {
  beanstalk_env=${1}

  if [ $(list_beanstalk_envs | grep "^${beanstalk_env}$" -c) -eq 0 ]; then
    echo "Environment not recognized: '${beanstalk_env}'. Use one of the following:"
    echo
    echo "$(list_beanstalk_envs)"
    exit 1
  fi
}

function assert_number_of_arguments() {
	actual_args="${1}"
	expected_args="${2}"
	msg=${3}
	
	if [[ "${actual_args}" != "${expected_args}" ]]; then
		echo "Wrong number of arguments."
		echo "Got ${actual_args}, expected ${expected_args}."
		echo
	    echo "${msg}"
	    exit 1
	fi
}

function assert_minimum_number_of_arguments() {
        actual_args="${1}"
        expected_args="${2}"
        msg=${3}

        if [[ "${actual_args}" < "${expected_args}" ]]; then
                echo "Wrong number of arguments."
                echo "Got ${actual_args}, expected at least ${expected_args}."
                echo
            echo "${msg}"
            exit 1
        fi
}

