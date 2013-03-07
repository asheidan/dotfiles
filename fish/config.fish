set fish_greeting


if status -l
	echo "Im a login shell"
	if not set -q __fish_has_read_etcpaths
		if [ -f "/usr/libexec/path_helper" ]
			eval (/usr/libexec/path_helper -c | sed 's/[:"]/ /g')
		end
		set -gx __fish_has_read_etcpaths
	end
	if not contains "$HOME/bin" $PATH
		if test -d $HOME/bin
			set -x PATH $HOME/bin $PATH
		end
	end
end

if not set -q __fish_prompt_user
	set -g __fish_prompt_user (set_color --bold white)
end

if not set -q __fish_prompt_cwd
	# set -g __fish_prompt_cwd (set_color $fish_color_cwd)
	set -g __fish_prompt_cwd (set_color magenta)
end

if not set -q __fish_prompt_contexts
	set -g __fish_prompt_contexts (set_color green)
end

if not set -q __fish_prompt_decorators
	set -g __fish_prompt_decorators (set_color --bold black)
end

function __extended_info -d "Small function that shows additional information"
	# Save info to restore later
	#set __cmd_line (commandline)
	#set __cmd_cursor (commandline --cursor)
	# Clear line
	echo
	# Info
	echo "Current directory:" (pwd)
	if test -d .git
		echo "Git repo"
	end
	#commandline $__cmd_line
	#commandline --cursor $__cmd_cursor
	#fish_prompt
	commandline -f repaint
end

function git_revision #{{{1
	set -l git_dir
	if [ -d .git ]
		set git_dir "$PWD/.git"
	else
		set git_dir (git rev-parse --git-dir 2> /dev/null)
	end
	if [ -z "$git_dir" ]
		set -e git_repo
		return
	end

	# Try to find out our current branch
	set -l git_branch
	if [ -z "$git_branch" ]; set git_branch (git symbolic-ref HEAD 2> /dev/null | sed 's_refs/heads/__'); end
	if [ -z "$git_branch" ]; set git_branch (git describe --exact-match HEAD 2> /dev/null); end
	if [ -z "$git_branch" ]; set git_branch (cut -c1-7 "$git_dir/HEAD")"..."; end

	set -g git_repo
	set git_repo (echo $git_dir | sed 's_/\.git$__')
	# echo $git_repo > /dev/stderr
	
	echo $git_branch
end #}}}1

function collect_contexts -d "Returns a space separated list of contexts" #{{{1
	set virtualenv (basename "$VIRTUAL_ENV")
	set git_rev (git_revision)
	set context_list
	if [ -n "$virtualenv" ]; set context_list $context_list "v:$virtualenv"; end
	if [ -n "$git_rev" ]; set context_list $context_list "g:$git_rev"; end
	for context in $context_list
		echo $context
	end | sort
end #}}}1

function fish_prompt_info_put
	set -l l_sep '['
	set -l r_sep ']'
	if [ 2 -lt (count $argv) ]
		set l_sep $argv[3]
		set r_sep $argv[4]
	end
	echo -n -s "$__fish_prompt_decorators" "$l_sep" "$__fish_prompt_normal" $argv[1]
	if [ 1 -lt (count $argv) ]
		echo -n -s $argv[2]
	end
	echo -n -s "$__fish_prompt_decorators" "$r_sep" ' '
end

function fish_prompt --description 'Write out the prompt'
	
	# Just calculate these once, to save a few cycles when displaying the prompt
	if not set -q __fish_prompt_hostname
		set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
	end

	if not set -q __fish_prompt_normal
		set -g __fish_prompt_normal (set_color normal)
	end

	switch $USER

		case root

		if not set -q __fish_prompt_cwd
			if set -q fish_color_cwd_root
				set -g __fish_prompt_cwd (set_color $fish_color_cwd_root)
			else
				set -g __fish_prompt_cwd (set_color $fish_color_cwd)
			end
		end

		echo -n -s "$USER" @ "$__fish_prompt_hostname" ' ' "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal" '# '

		case '*'

		set contexts (collect_contexts)

		# if [ 20 -lt (echo $contexts | wc -c) ]; echo; end
		fish_prompt_info_put "$__fish_prompt_cwd" (path_format -bu "$git_repo")
		for context in $contexts
			fish_prompt_info_put "$__fish_prompt_contexts" "$context"
		end
		fish_prompt_info_put "$__fish_prompt_user" "$USER""$__fish_prompt_decorators"@"$__fish_prompt_user""$__fish_prompt_hostname"
		echo
		echo -n -s '[' "$__fish_prompt_normal" ' '

	end
end

function fish_title
	# Setting title
	echo $PWD
end

#bind -a \cv __extended_info
