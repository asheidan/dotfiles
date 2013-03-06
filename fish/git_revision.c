#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
#include <spawn.h>

const char * const GIT_DIR_NAME = ".git";
const char * const GIT_HEAD_INFO = "HEAD";

const size_t SHA_SHORT_LENGTH = 7;

// const char * const GIT_COMMAND = "git";
char * const GIT_ARGS_COMMIT = "git symbolic-ref -q --short HEAD";
char * const GIT_ARGS_HEADSHA = "git rev-parse HEAD";
char * const GIT_ARGS_REFRESH = "git update-index -q --refresh";
char * const GIT_ARGS_INDEX = "git diff-index --exit-code --quiet --cached HEAD --ignore-submodules --";
char * const GIT_ARGS_FILES = "git diff-files --exit-code --quiet --ignore-submodules --";

typedef enum {
	GIT_REFERENCE,
	GIT_UNKNOWN
} GIT_REF_TYPE;

typedef enum {
	GIT_SUCCESS = 0,
	GIT_DIFFER = 256,
	GIT_NOT_A_REPO = 32768
} GIT_RETURN_CODE;

bool is_dir(const char * const path)
{
	struct stat
		info;

	return !stat(path, &info) && (0 != (info.st_mode & S_IFDIR));
}

void get_to_git_dir()
{
	char
		buffer[2];

	while (! is_dir(GIT_DIR_NAME)) {
		if (NULL == getcwd(buffer, 2)) {
			if (errno != ERANGE) {
				perror("git_revision");
				exit(2);
			}
		}
		else {
			exit(3);
		}

		if (0 != chdir("..")) {
			perror("git_revision");
			exit(1);
		}
	}
}

char * line_from_stream(FILE * stream)
{
	const size_t MAX_LINE_LEN = 1024;
	size_t length;
	char buffer[ MAX_LINE_LEN ];

	char *result = NULL;

	if (fgets(buffer, MAX_LINE_LEN, stream) != NULL) {
		length = strcspn(buffer, "\n");
		buffer[length] = '\0';

		result = strndup(buffer, length);
	}

	return result;
}

GIT_REF_TYPE parse_head(const char * line)
{
	if (0 == strncmp(line, "ref: ", 5)) {
		return GIT_REFERENCE;
	}
	else {
		return GIT_UNKNOWN;
	}
}

char * ref_from_line(const char * line)
{
		// Remove "ref: refs/heads/"
		return strdup(line + 16);
}

char * sha_from_line(const char * line)
{
	char *result;

	result = strndup( line, SHA_SHORT_LENGTH );
	return result;
}

char * commit_name_from_stream(FILE *head)
{
	char
		*line,
		*result = NULL;

	line = line_from_stream( head );

	if (GIT_REFERENCE == parse_head(line)) {
		// Remove "ref: refs/heads/"
		result = ref_from_line( line );
	}
	else {
		result = sha_from_line( line );
	}

	free( line );
	return result;
}

int execute(
		const char * const command,
		char * const buffer,
		const size_t buf_size)
{
	int exit_code = 0;
	
	if (NULL != buffer && 0 < buf_size) {
		FILE *output;
		char *buf_p = buffer;
		size_t read_size = 0, current_read;
		
		output = popen(command, "r");
		while (0 < (buf_size - read_size) && !feof(output) && !ferror(output)) {
			current_read = fread(buf_p, sizeof(char), buf_size - read_size, output);
			buf_p += current_read;
			read_size += current_read;
		}
		exit_code = pclose(output);
	}
	else {
		exit_code = system(command);
	}
	return exit_code;
}

int main(int argc, char** argv)
{
	const size_t
		buf_size = 1024;
	char
		buffer[buf_size];
	char
		*commit = NULL;
	int
		status = 0;
	bool
		files = false,
		index = false;

	// Path walk to get git-dir
	//get_to_git_dir();


	status = execute( GIT_ARGS_COMMIT, buffer, buf_size );
	if (GIT_NOT_A_REPO == status) {
		fprintf(stdout, "(No repo)\n" );
		return status;
	}
	if (GIT_DIFFER == status) {
		status = execute(GIT_ARGS_HEADSHA, buffer, buf_size);
		if (GIT_SUCCESS == status) {
			buffer[ SHA_SHORT_LENGTH ] = '\0';
		}
		else {
			buffer[0] = '\0';
		}
	}
	buffer[ strcspn( buffer, "\n" ) ] = '\0';
	commit = strdup( buffer );

	execute( GIT_ARGS_REFRESH, NULL, 0 );
	index = (GIT_DIFFER == execute( GIT_ARGS_INDEX, NULL, 0 ));
	files = (GIT_DIFFER == execute( GIT_ARGS_FILES, NULL, 0 ));

	// Parse content

	// Check dirty-status
	// format output
	fprintf( stdout, "%s", commit );
	if (files || index) {
		fprintf( stdout, "(%c%c)" , (index ? 'I' : ' ') , (files ? 'F' : ' ') );
	}
	fprintf( stdout, "\n" );
	
	free( commit );
	return 0;
}
