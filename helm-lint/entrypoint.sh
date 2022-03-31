#!/bin/bash -l

function helmTemplate {
  echo "1. Trying to render templates with provided values"
  CHART_LOCATION=$1
  HELM_TEMPLATE_TMP=$2
  if [[ ! -z "$1" ]] && [[ ! -z "$2" ]]; then
	  echo "helm template $CHART_LOCATION"
	  echo "----------------------------------------"
	  helm dependency update "$CHART_LOCATION"
	  helm template "$CHART_LOCATION" > "$HELM_TEMPLATE_TMP/template.yaml"
	  HELM_TEMPLATE_EXIT_CODE=$?
	  echo "----------------------------------------"
	  if [ $HELM_TEMPLATE_EXIT_CODE -eq 0 ]; then
	    echo "Result: SUCCESS"
	  else
	    echo "Result: FAILED"
	  fi
	  return $HELM_TEMPLATE_EXIT_CODE
  else
    echo "Skipped due to condition: Arguments not provided"
    return $1
  fi
  return 0
}

function helmLint {
  echo "----------------------------------------"
  echo "2. Checking a chart for possible issues"
  HELM_TEMPLATE_TMP=$1
  if [[ "$2" -eq 0 ]]; then
	  if [ -z "$HELM_TEMPLATE_TMP" ]; then
	    echo "Skipped due to condition: \$HELM_TEMPLATE_TMP is not provided"
	    return -1
	  fi
	  if [[ -z "${INPUT_LINTER_CONFIG}" ]]; then
	     CONFIG=""
	  else
	     CONFIG="--config ${INPUT_LINTER_CONFIG}"
	  fi
	  echo "helm lint $HELM_TEMPLATE_TMP/template.yaml"
	  echo "----------------------------------------"
	  kube-linter $CONFIG lint "$HELM_TEMPLATE_TMP/template.yaml"
	  HELM_LINT_EXIT_CODE=$?
	  echo "----------------------------------------"
	  if [ $HELM_LINT_EXIT_CODE -eq 0 ]; then
	    echo "Result: SUCCESS"
	  else
	    echo "Result: FAILED"
	  fi
	  return $HELM_LINT_EXIT_CODE
  else
    echo "Skipped due to failure: Previous step has failed"
    return $2
  fi
  return 0
}



function summaryReport {
  echo "------------------------------------------------------------------------------------------"
  echo "3. Summary"
  if [[ "$1" -eq 0 ]]; then
    echo "Examination is completed; no errors found!"
    return 0
  else
    echo "Examination is completed; errors found, check the log for details!"
    return 1
  fi
}



for CHART_LOCATION in $(find "${INPUT_CHART_LOCATION}" -iname "Chart.yaml" -print 2>/dev/null | xargs -n1 dirname); do
	HELM_TEMPLATE_TMP="$(mktemp -dt helm-template-XXXXXX)"
	helmTemplate "$CHART_LOCATION" "$HELM_TEMPLATE_TMP"
    helmLint "$HELM_TEMPLATE_TMP" $?
    summaryReport $?
done || exit 1
