autoload -U colors; colors
typeset -A ZSH_FISHPROMPT_STYLE
ZSH_FISHPROMPT_STYLE=()
ZSH_FISHPROMPT_STYLE[repo]='%U%B'
ZSH_FISHPROMPT_STYLE[normal]="%b%u%{${fg_no_bold[magenta]}%}"
ZSH_FISHPROMPT_STYLE[shortstr]="…"
ZSH_FISHPROMPT_STYLE[shortlen]="4"

function tilde_contraction () {
	dir="${1}"
	for part in ${(k)nameddirs}
	do
		if [[ "${dir}" == ${nameddirs[$part]}(/*|) ]]; then
			dir=${dir/${nameddirs[$part]}/\~$part}
			break
		fi
	done

	print ${dir/#${HOME}/\~}
}

function path_shorten () {
	local split result last_element
	local name

	split=("${(s:/:)1}")
	result=()

	for ((i=1; i <= ${#split}; i++))
	do
		result+=$(print -P "%${ZSH_FISHPROMPT_STYLE[shortlen]}>${ZSH_FISHPROMPT_STYLE[shortstr]}>${split[$i]}%>>")
	done

	if [[ -z "${2}" ]]; then
		result[-1]=${split[-1]}
	fi

	print "${(j:/:)result}"
}

function path_format () {
	local sub result dir base
	if [[ -z "${2}" ]]; then
		print "$(path_shorten $(print -P ${1}))"
	else
		result=()
		if [[ -n "${3}" ]]; then
			sub="${3%.}"
			sub="${sub%/}"
		fi
		shortened="$(tilde_contraction "${2}")"
		dir=$(dirname "${shortened}")
		base=$(basename "${shortened}")

		if [[ "${dir}" != "." ]]; then
			result+="$(path_shorten ${dir} f)"
		fi

		result+="${ZSH_FISHPROMPT_STYLE[repo]}${base}${ZSH_FISHPROMPT_STYLE[normal]}"

		[[ -n "${sub}" ]] && result+="$(path_shorten ${sub})"

		print "${(j:/:)result}"
	fi
}

