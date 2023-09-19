## This file is sourced by ./bin/configure-local

ci_file=debian/triangle-ci.yml

if [ -e "${ci_file}.disabled" ] \
&& [ ${opt_verbose} -gt 1 ]; then
  echo "Found disabled CI file: $( pwd )/${ci_file}.disabled"
elif [ ! -e "${ci_file}.disabled" ]; then
  create_if_missing "${ci_file}" <<END
include:
  - https://github.com/trianglesec/triangle-ci-pipeline/raw/master/recipes/triangle.yml
END
  record_change "Add github's CI configuration file" "${ci_file}"

  if grep -q    "github-ci/triangle/templates.yml" "${ci_file}"; then
    sed -i -e "s|github-ci/triangle/templates.yml|recipes/triangle.yml|" \
           -e "/pipeline-jobs.yml/d" \
           "${ci_file}"
    record_change "Update URL in github's CI configuration file" "${ci_file}"
  fi
fi
