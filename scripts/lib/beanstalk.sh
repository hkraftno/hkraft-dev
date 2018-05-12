
function list_beanstalk_envs() {
	envchain aws eb list | sed 's/^\* //'
}

function default_number_of_nodes_for() {
	vpc_name="${1}"

	if [[ "${vpc_name}" == "prod" ]]; then
	  echo "2"
	else
	  echo "1"
	fi
}
