set fish_greeting

if test -d $HOME/bin; set -x PATH $HOME/bin $PATH; end

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

function git_revision
	set -l git_dir
	if [ -d .git ]
		set git_dir (pwd).git
	else
		set git_dir (git rev-parse --git-dir 2> /dev/null)
	end
	if [ -z "$git_dir" ]; return; end

	# Try to find out our current branch
	set -l git_branch
	if [ -z "$git_branch" ]; set git_branch (git symbolic-ref HEAD 2> /dev/null | sed 's_refs/heads/__'); end
	if [ -z "$git_branch" ]; set git_branch (git describe --exact-match HEAD 2> /dev/null); end
	if [ -z "$git_branch" ]; set git_branch (cut -c1-7 "$git_dir/HEAD")"..."; end

	set -l git_path
	set git_path (echo $git_dir | sed 's_\.git$__')
	
	set -l git_repo
	set git_repo (basename "$git_path")

	set -l git_rel
	set git_rel (pwd | sed "s-$git_path--")
	
	echo $git_branch'@'$git_repo':/'$git_rel
end

function collect_contexts -d "Returns a space separated list of contexts"
	set virtualenv (basename "$VIRTUAL_ENV")
	set git_rev (git_revision)
	set context_list
	if [ -n "$virtualenv" ]; set context_list $context_list "v:$virtualenv"; end
	if [ -n "$git_rev" ]; set context_list $context_list "g:$git_rev"; end
	if [ 0 -lt (count $context_list) ]
		echo "$context_list"
	end
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

		if not set -q __fish_prompt_cwd
			set -g __fish_prompt_cwd (set_color $fish_color_cwd)
		end

		if not set -q __fish_prompt_contexts
			set -g __fish_prompt_contexts (set_color --bold black)
		end

		set contexts (collect_contexts)
		echo -n "$__fish_prompt_contexts""["$contexts"] ""$__fish_prompt_normal"
		if [ 20 -lt (echo $contexts | wc -c) ]; echo; end
		echo -n -s "$USER" @ "$__fish_prompt_hostname" ' ' "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal" '> '

	end
end

function fish_title
	# Setting title
	pwd
end

#bind -a \cv __extended_info
