## This file is sourced by ./bin/configure-local

control_file=debian/control
copyright_file=debian/copyright

SOURCE=$( awk '/^Source:/ {print $2}' ${control_file} )
CURDIR_NAME=$( basename "${PWD}" )

rename_orig_vcs() {
  local type=
  local url=
  local origin=

  for type in $@; do
    grep -i -q "^Vcs-${type}:" "$control_file" \
      || continue

    url=$( sed -n "s|^Vcs-${type}: *||ip" "${control_file}" )
    case "${url}" in
      *debian.org*)    origin=Debian ;;
      *trianglesec*)     origin=Triangle ;;
      *launchpad.net*) origin=Ubuntu ;;
      *RPi-Distro*)    origin=Raspberry ;;
      *)               origin=Original ;;
    esac

    [ "${origin}" != Triangle ] \
      || continue

    sed -i -e "s|^Vcs-${type}: \(.*\)|XS-${origin}-Vcs-${type}: \1|i" "${control_file}"
  done
}

set_triangle_vcs() {
  local type=$1
  local url=$2
  local lineno=

  if grep -i -q "^Vcs-${type}:" "${control_file}"; then
    sed -i -e "s|^Vcs-${type}: .*|Vcs-${type}: ${url}|i" "${control_file}"
  elif grep -i -q "^XS-.*-Vcs" "${control_file}"; then
    lineno=$( grep -i -n "^XS-.*-Vcs" "${control_file}" | tail -1 | cut -f1 -d: )
    sed -i -e "${lineno}a Vcs-${type}: ${url}" "${control_file}"
  else
    lineno=$( grep -n "^ *$" "${control_file}" | head -1 | cut -f1 -d: )
    sed -i -e "${lineno}i Vcs-${type}: ${url}" "${control_file}"
  fi
}

if [ "${CURDIR_NAME}" != "${SOURCE}" ]; then
  echo "WARNING: ${PWD} is not named after the source package (${SOURCE})"
fi

## Maintainer
if grep -q -E "Maintainer: .*(triangle|offensive-security|offsec|hertzog|sophie@freexian)" "${control_file}"; then
  sed -i -e "s|^Maintainer: .*|Maintainer: Triangle Developers <devel@triangle.org>|i" "${control_file}"
else
  sed -i -e "s|^Maintainer: \(.*\)|XSBC-Original-Maintainer: \1\nMaintainer: Triangle Developers <devel@triangle.org>|i" "${control_file}"
fi
record_change "Update Maintainer field" ${control_file}

## VCS-*
rename_orig_vcs Browser Bzr Git Svn
set_triangle_vcs Browser "https://github.com/trianglesec/packages/${SOURCE}"
set_triangle_vcs Git "https://github.com/trianglesec/packages/${SOURCE}.git"
unset rename_orig_vcs
unset set_triangle_vcs
record_change "Update Vcs-* fields" "${control_file}"

## Homepage
sed -i -e "s|^Homepage: http://trianglesec.github.io|Homepage: https://trianglesec.github.io|i" "${control_file}"
if [ -e ${copyright_file} ]; then
  sed -i -e "s|^Source: http://trianglesec.github.io|Source: https://trianglesec.github.io|i" "${copyright_file}"
  extra=${copyright_file}
fi
record_change "Use HTTPS URL for trianglesec.github.io" "${control_file}" "${extra}"
