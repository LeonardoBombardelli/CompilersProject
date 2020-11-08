# Etapa1

### Objective evaluation — 9.77 (84 out of 86 test files)
- The lexical analyzer recognizes the shift operators swapped (one as the other), which resulted in errors in test files `entrada_054` and `entrada_055`. This problem was fixed in Etapa2.

### Subjective evaluation — 9.5
- In the recognition of special chars, we returned the chars themselves (hardcoded) instead of returning `yytext[0]`. This problem was fixed in Etapa2.