#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define LENGTH 256

const char *booring_chars = "._-~";

void usage(void)
{
}

int main(int argc, char **argv)
{
	const char *home = getenv("HOME");
	char *pwd  = strdup(getenv("PWD"));
	char *p = pwd;

	char result_buffer[LENGTH];
	char cache_buffer[LENGTH];

	char *result = result_buffer;
	char *cache  = cache_buffer;
	char *token;

	char ch;

	char bold      = 0;
	char underline = 0;
	char italic    = 0;
	char reversed  = 0;

	int dir_len = 3;
	int len;

	char truncated = 0;

	while ((ch = getopt(argc, argv, "iburn:")) != -1) {
		switch (ch) {
			case 'b':
				bold = 1;
				break;
			case 'u':
				underline = 1;
				break;
			case 'i':
				italic = 1;
				break;
			case 'r':
				reversed = 1;
				break;
			case 'n':
				dir_len = (int)strtoul(optarg, NULL, 0);
				break;
			default:
				usage();
				return 0;
		}
	}
	argc -= optind;
	argv += optind;

	//fprintf( stderr, "optind: %d\targc: %d\n", optind, argc);

	/*
	fprintf( stderr, "home: %s\n", home );
	fprintf( stderr, "pwd:  %s\n", pwd );
	*/

	for (token = strtok(pwd, "/"); token; token = strtok(NULL,"/")) {
		//fprintf(stderr, "%s\n", token);

		if ((dir_len > 1) && truncated) {
			*result = '~';
			++result;
		}

		truncated = 0;

		cache += sprintf(cache, "/%s", token);
		//fprintf(stderr, "%s\n", cache_buffer);

		if (0 == strcmp(cache_buffer, home)) {
			result = result_buffer;
			result += sprintf(result, "~");
		}
		else if ((1 <= argc) && (0 == strcmp(cache_buffer, argv[0]))) {
			*result = '/';
			++result;
			if (bold)      { result += sprintf(result, "\e[1m"); }
			if (italic)    { result += sprintf(result, "\e[3m"); }
			if (underline) { result += sprintf(result, "\e[4m"); }
			if (reversed)  { result += sprintf(result, "\e[7m"); }
			result += sprintf(result, "%s", token);
			if (reversed)  { result += sprintf(result, "\e[27m"); }
			if (underline) { result += sprintf(result, "\e[24m"); }
			if (italic)    { result += sprintf(result, "\e[23m"); }
			if (bold)      { result += sprintf(result, "\e[22m"); }
		}
		else {
			len = sprintf(result, "/%s", token);
			if (dir_len <= 1) {
				result += 2;
			}
			else if (len <= (dir_len + 2)) {
				result += len;
			}
			else {
				result += dir_len + 1;
				truncated = 1;
			}
			//fprintf(stderr, "%s\n", result_buffer);
		}
		//fprintf(stderr, "%s\n", result_buffer);
		//fprintf(stderr, "----------\n");
	}

	fprintf( stdout, "%s\n", result_buffer );
	free(pwd);
	return 0;
}
