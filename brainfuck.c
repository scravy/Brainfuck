#include "stdio.h"
#include "stdlib.h"

#define VERSION "v2011-05-17 03:57 CET -- brainfuck interpreter by tiredness can kill at warhog dot net"

#define MEM 30000
#define BUF 4096
#define STK 1024

int main(int argc, char** argv) {
	char* code = 0;
	long length = 0;
	long buf = BUF;
	long max = MEM;
	long stk = STK;
	int* stack = 0;
	int* memory = 0;
	char extensions = 0;
	
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
			} else if (n == 'x') {
				extensions |= 1;
			} else if (n == 's') {
				extensions |= 1;
				stk = atoi(argv[++i]);
			} else if (n == 'c') {
				extensions |= 2;
			} else if (n == 'w') {
				extensions |= 4;
			} else if (n == 'o') {
				extensions |= 8;
			} else if (n == 'p') {
				extensions |= 32;
			} else if (n == 'h') {
				printf("  -%c  %s %i\n", 'm', "memory size - defaults to", MEM);
				printf("  -%c  %s\n", 'b', "buffer size (for reading from stdin)");
				printf("  -%c  %s\n", 'r', "run piece of code from command line arguments");
				printf("  -%c  %s\n", 'x', "enables extensions (@${}=#_*/%&|^?!)");
				printf("  -%c  %s\n", 's', "stack size (implies -x)");
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
		
		if (!(extensions & 32)) {
			for (i = 0; i < length; i++) {
				if (code[i] == '[') c++;
				if (code[i] == ']') c--;
				if (c < 0) return 1;
			}
			if (c != 0) return 1;
		}
		
		if (extensions & 8) {
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
		if (extensions & 2) {
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
						if (extensions & 4) {
							printf("\tmemory[p] %%= %li;\n", max);
						}
						c = 0;
					} else if (p == '-') {
						if (extensions & 4) {
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
		
		if (!(memory = malloc(max))) return 3;
		if (extensions & 1) if (!(stack = malloc(stk))) return 3;
		
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
				if (extensions & 1) {
#define push(x) stack[sp++] = x
#define pop()   stack[--sp]
					switch (code[i]) {
					case '$':
						printf("%c", '\n');
						break;
					case '@':
						printf("%i", memory[p]);
						break;
					case '{':
						push(memory[p]);
						break;
					case '}':
						memory[p] = pop();
						break;
					case '*':
						c = pop();
						memory[p] = c * pop();
						break;
					case '/':
						c = pop();
						memory[p] = c / pop();
						break;
					case '=':
						c = pop();
						memory[p] = c == pop();
						break;
					case '%':
						c = pop();
						memory[p] = c % pop();
						break;
					case '&':
						c = pop();
						memory[p] = c & pop();
						break;
					case '|':
						c = pop();
						memory[p] = c | pop();
						break;
					case '^':
						c = pop();
						memory[p] = c ^ pop();
						break;
					case '#':
						c = pop();
						memory[p] = c + pop();
						break;
					case '_':
						c = pop();
						memory[p] = c - pop();
						break;
					case '?':
						memory[p] = sp > 0;
						break;
					case ';':
						i += memory[p] - 1;
						break;
					case '!':
						return memory[p] % 256;
						break;
					}
				}
			}
		}
	}
	return 0;
}

