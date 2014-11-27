#include "stdio.h"
#include "stdlib.h"

#define VERSION "Thu Nov 27 04:13:16 CET 2014 -- brainfuck interpreter by tiredness can kill at warhog dot net"

#define MEM 30000
#define BUF 4096

#define OPT_COMPILE 2
#define OPT_WRAP 4
#define OPT_OOK 8
#define OPT_NO_PARENTHESIS_CHECK 16

int main(int argc, char** argv)
{    
	char* code = 0;
	long length = 0;
	long buf = BUF;
	long max = MEM;
	int* memory = 0;
	char options = 0;
	
	int i;
	char* file = 0;
	
	for (i = 1; i < argc; i++) {
		if (argv[i][0] == '-') {
			char n = argv[i][1];
			if (n == '-') {
				n = argv[i][2];
			}
			if (n == 'm') {
				max = atoi(argv[++i]);
			} else if (n == 'b') {
				buf = atoi(argv[++i]);
			} else if (n == 'r') {
				code = argv[++i];
				while (code[length] != '\0') {
					length++;
				}
			} else if (n == 'c') {
				options |= OPT_COMPILE;
			} else if (n == 'w') {
				options |= OPT_WRAP;
			} else if (n == 'o') {
				options |= OPT_OOK;
			} else if (n == 'p') {
				options |= OPT_NO_PARENTHESIS_CHECK;
			} else if (n == 'h') {
				printf("  -%c  %s %i\n", 'm', "memory size - defaults to", MEM);
				printf("  -%c  %s\n", 'b', "buffer size (for reading from stdin)");
				printf("  -%c  %s\n", 'r', "run piece of code from command line arguments");
				printf("  -%c  %s\n", 'o', "translate to ook!");
				printf("  -%c  %s\n", 'c', "create c code");
				printf("  -%c  %s\n", 'w', "wrap pointer (only with -c)");
				printf("  -%c  %s\n", 'p', "don't check parenthesis (use with care)");
				printf("  -%c  %s\n", 'h', "this help");
				printf("  -%c  %s\n", 'v', "print version information");
				return 0;
			} else if (n == 'v') {
				printf("%s\n", VERSION);
				return 0;
			}
		} else if (!(file || code)) {
			file = argv[i];
		}
	}
	
	if (!code) {
		if (!file) {
			if (!(code = malloc(buf))) {
				return 3;
			}
			length = fread(code, 1, buf, stdin);
		} else {
			FILE* f;
			
			if (!(f = fopen(file, "rb"))) {
				return 2;
			}
			fseek(f, 0, SEEK_END);
			length = ftell(f);
			fseek(f, 0, SEEK_SET);
			if (!(code = malloc(length))) {
				return 3;
			}
			fread(code, 1, length, f);
			fclose(f);
		}
	}
	
	if (code) {
		int max1, p, sp, c = 0;
		
		if (!(options & OPT_NO_PARENTHESIS_CHECK)) {
			for (i = 0; i < length; i++) {
				if (code[i] == '[') c++;
				if (code[i] == ']') c--;
				if (c < 0) return 1;
			}
			if (c != 0) return 1;
		}
		
		if (options & OPT_OOK) {
			for (i = 0; i < length; i++) {
				switch (code[i]) {
				case '>': printf("Ook. Ook? "); break;
				case '<': printf("Ook? Ook. "); break;
				case '+': printf("Ook. Ook. "); break;
				case '-': printf("Ook! Ook! "); break;
				case '.': printf("Ook! Ook. "); break;
				case ',': printf("Ook. Ook! "); break;
				case '[': printf("Ook! Ook? "); break;
				case ']': printf("Ook? Ook! "); break;
				default: continue;
				}
				if (++c % 8 == 0) printf("\n");
			}
			if (c % 8) printf("\n");
			return 0;
		}
		if (options & OPT_COMPILE) {
			printf("%s\n\n",    "#include \"stdio.h\"");
			printf("%s\n\n",    "#include \"stdlib.h\"");
			printf("%s\n",      "int main() {");
			printf("\tint* memory = malloc(%li);\n", max);
			printf("\t%s\n",    "int p = 0;");
			printf("\t%s\n",    "if (!memory) return 2;");
			p = '\0';
			for (i = 0; i < length; i++) {
				switch (code[i]) {
					case '>': case '<': case '+': case '-': case '[': case ']': case '.': case ',': break;
					default: continue;
				}
				if (code[i] != p) {
					if (p == '+') {
						printf("\tmemory[p] += %i;\n", c);
						if (options & 4) {
							printf("\tmemory[p] %%= %li;\n", max);
						}
						c = 0;
					} else if (p == '-') {
						if (options & 4) {
							printf("\tmemory[p] += %li;\n", max - c);
							printf("\tmemory[p] %%= %li;\n", max);
						} else {
							printf("\tmemory[p] -= %i;\n", c);
						}
						c = 0;
					}
				}
				switch (code[i]) {
				case '>':
					printf("\t%s\n", "p++;");
					break;
				case '<':
					printf("\t%s\n", "p--;");
					break;
				case '+':
					c++;
					break;
				case '-':
					c++;
					break;
				case '[':
					printf("\t%s\n", "while (memory[p])\n\t{");
					break;
				case ']':
					printf("\t%s\n", "}");
					break;
				case '.':
					printf("\t%s\n", "putchar(memory[p]);");
					break;
				case ',':
					printf("\t%s\n", "memory[p] = getchar();");
					break;
				default:
					continue;
				}
				p = code[i];
			}
			printf("\t%s\n", "return 0;\n}");
			return 0;	
		}
		
		if (!(memory = malloc(max))) {
            return 3;
        }
		
		max1 = max - 1;
		p = 0;
		sp = 0;
		
		for (i = 0; i < max; i++) {
			memory[i] = 0;
		}
		for (i = 0; i < length; i++) {
			switch (code[i]) {
			case '>':
				p++;
				p %= max;
				break;
			case '<':
				p += max1;
				p %= max;
				break;
			case '+':
				memory[p]++;
				break;
			case '-':
				memory[p]--;
				break;
			case '.':
				putchar(memory[p]);
				fflush(stdout);
				break;
			case ',':
				memory[p] = getchar();
				break;
			case '[':
				if (memory[p] == 0) {
					i++;
					for (c = 0; code[i] != ']' || c != 0; i++) {
						switch (code[i]) {
							case '[': c++; break;
							case ']': c--; break;
						}
					}
				}
				break;
			case ']':
				if (memory[p] != 0) {
					i--;
					for (c = 0; code[i] != '[' || c != 0; i--) {
						switch (code[i]) {
							case ']': c++; break;
							case '[': c--; break;
						}
					}
				}
				break;
			default:
                continue;
			}
		}
	}
	return 0;
}

