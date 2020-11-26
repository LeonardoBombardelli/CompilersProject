#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
extern int yyparse(void);
extern int yylex_destroy(void);

int only_iloc = 0;
void *arvore = NULL;
void exporta (void *arvore);
void libera (void *arvore);

int main (int argc, char **argv)
{
  char c;
  int err = 1;

  /* Parse program options using getopt (see documentation in
     https://www.gnu.org/software/libc/manual/html_node/Getopt.html) */
  while ((c = getopt(argc, argv, "ioh")) != -1)
  {
    switch(c)
    {
      case 'i':
        only_iloc = 1;
        break;

      case 'o':
        // turn on optimization option
        break;

      case 'h':
        err = 0;
      default:
        printf("Usage: %s [OPTIONS]\n\n", argv[0]);
        printf("OPTIONS:\n");
        printf("  -i\tCompile to ILOC (default is x86_64 Assembly).\n");
        printf("  -o\tTurn on code optimization.\n");
        printf("  -h\tDisplay this information and exit.\n\n");
        printf("Source code is read from stdin.\n");
        exit(err);
    }
  }

  int ret = yyparse(); 
  exporta (arvore);
  libera(arvore);
  arvore = NULL;
  yylex_destroy();
  return ret;
}
