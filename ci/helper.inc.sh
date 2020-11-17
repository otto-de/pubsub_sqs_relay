function deployTf {
  local deployment="${1}"
  local environment="${2}"
  shift; shift
  local tf_extra_args="${@}"

  pushd "${SCRIPT_DIR}/../terraform/${deployment}" > /dev/null || exit
    tfenv install
    tfenv use
    tfenv exec init ${TF_ARGS}
    tfenv exec workspace select "${environment}" || tfenv exec workspace new "${environment}"
    if [[ -f "${environment}.tfvars" ]]; then
      TF_ENV_VARS="-var-file=${environment}.tfvars"
    fi

    if [[ -n "${DRY_RUN}" ]]; then
      tfenv exec plan ${TF_ENV_VARS} ${tf_extra_args} ${TF_ARGS}
    else
      tfenv exec apply ${TF_ENV_VARS} -input=false -auto-approve ${tf_extra_args} ${TF_ARGS}
    fi
  popd > /dev/null || exit
}