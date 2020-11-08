# Etapa3

**Late submission**: there is a 20% discount as we submitted this phase late, so the grades are respectively 7.896 and 7.96.

### Objective evaluation — 9.87 (76 out of 77 test files)
- The analyzer didn't recognize multiple simultaneous local var declarations (e.g. `int a, b;`) as syntactically valid. This was not explicitly specified in the grammar of the language (see E2.pdf), and many other groups didn't recognize as well. Schnorr didn't test this in this phase but asked to correct it. This problem was fixed in Etapa4.
- We weren't dealing correctly with local var declarations, specifically when an identifier is attributed to the declared var (as in test file `w70`, with `int a <= b;`). Instead of creating the `var_init` node with two `var_access`s, we created a node literal with the right identifier. As the identifier doesn't have a valid literal type, this resulted in garbage as the label of the node. This problem was fixed in Etapa4.

### Subjective evaluation — 9.95
- Not sure why we didn't get a 10 here...