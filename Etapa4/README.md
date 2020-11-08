# Etapa4

**Late submission**: there is a 20% discount as we submitted this phase late, so the grades are respectively 7.33 and 7.52.

### Objective evaluation — 9.17 (100 out of 109 test files)
- We got errors in test files `kal52` through `kal59` because of a misinterpretation of section 2.6 of E4.pdf. In cases where Schnorr expected the analyzer to throw `ERR_STRING_TO_X` and `ERR_CHAR_TO_X` we threw `ERR_WRONG_TYPE`. Almost all groups did it the same way we did.
    - **TODO**: maybe confirm with Schnorr if is really should be that way?
    - **TODO**: fix it in next phases?
- We got an error in `kal60` because we don't check correctly the string size for vars initialized on declarations.
    - **TODO**: fix it in next phases?

### Subjective evaluation — 9.4
- Not sure why we didn't get a 10 here...