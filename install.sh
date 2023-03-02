#!/bin/bash
#
# This is a rather minimal example Argbash potential
# Example taken from http://argbash.readthedocs.io/en/stable/example.html
#
# ARG_OPTIONAL_SINGLE([ipfs_pinner_tool_version],[],[version (commit sha, tag or 'latest') of ipfs-pinner tool to be used],[latest])
# ARG_OPTIONAL_SINGLE([output_location],[],[output location of generated ipfs-pinner binary],[./])
# ARG_OPTIONAL_SINGLE([repo_download_location],[],[location of repo to be downloaded],[./ipfs-pinner])
# ARG_OPTIONAL_BOOLEAN([remove_repo],[],[should delete repo once build is done?],[on])
# ARG_HELP([builds ipfs pinner tool)])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.9.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info
# Generated online by https://argbash.io/generate


die()
{
	local _ret="${2:-1}"
	test "${_PRINT_HELP:-no}" = yes && print_help >&2
	echo "$1" >&2
	exit "${_ret}"
}


begins_with_short_option()
{
	local first_option all_short_options='h'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_ipfs_pinner_tool_version="latest"
_arg_output_location="./"
_arg_repo_download_location="./ipfs-pinner"
_arg_remove_repo="on"


print_help()
{
	printf '%s\n' "builds ipfs pinner tool)"
	printf 'Usage: %s [--ipfs_pinner_tool_version <arg>] [--output_location <arg>] [--repo_download_location <arg>] [--(no-)remove_repo] [-h|--help]\n' "$0"
	printf '\t%s\n' "--ipfs_pinner_tool_version: version (commit sha, tag or 'latest') of ipfs-pinner tool to be used (default: 'latest')"
	printf '\t%s\n' "--output_location: output location of generated ipfs-pinner binary (default: './')"
	printf '\t%s\n' "--repo_download_location: location of repo to be downloaded (default: './ipfs-pinner')"
	printf '\t%s\n' "--remove_repo, --no-remove_repo: should delete repo once build is done? (on by default)"
	printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			--ipfs_pinner_tool_version)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_ipfs_pinner_tool_version="$2"
				shift
				;;
			--ipfs_pinner_tool_version=*)
				_arg_ipfs_pinner_tool_version="${_key##--ipfs_pinner_tool_version=}"
				;;
			--output_location)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_output_location="$2"
				shift
				;;
			--output_location=*)
				_arg_output_location="${_key##--output_location=}"
				;;
			--repo_download_location)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_repo_download_location="$2"
				shift
				;;
			--repo_download_location=*)
				_arg_repo_download_location="${_key##--repo_download_location=}"
				;;
			--no-remove_repo|--remove_repo)
				_arg_remove_repo="on"
				test "${1:0:5}" = "--no-" && _arg_remove_repo="off"
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
				;;
		esac
		shift
	done
}

parse_commandline "$@"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash



if [ "$_arg_ipfs_pinner_tool_version" == "latest" ]; then
  git clone https://github.com/covalenthq/ipfs-pinner.git --depth 1 $_arg_repo_download_location
else
  git clone https://github.com/covalenthq/ipfs-pinner.git $_arg_repo_download_location
  cd ipfs-pinner
  git checkout $_arg_ipfs_pinner_tool_version
  cd ..
fi

cd ipfs-pinner
make clean server-dbg
cd ..
mv ipfs-pinner/build/bin/server $_arg_output_location/server


if [ "$_arg_remove_repo" == "on" ]; then
  rm -rf ipfs-pinner
fi


# ] <-- needed because of Argbash