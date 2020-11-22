# Etapa5

**Late submission**: there is a 20% discount as we submitted this phase late, so the grades are respectively 4.92 and 6.54.

### Objective evaluation — 6.15 (62 out of 95 tests)
- There were 33 test files but there were a few verifications for each file.
- At line 580 of file `parser.y`, we (Artur :slightly_frowning_face:) had swapped the arguments' order during a refactoring (commit "created new ILOC..." from 15/11/2020). That caused almost *every* test file to fail — as it was an error in local var declaration. Schnorr identified this and (thankfully...) swapped it back to perform the tests.
#### Errors
- **(1 errors)** In test file `ijk14` we got one test wrong (value in stack equals 393) and one right (value in data segment equals 393). The execution appears to be correct for both tests.
    - **TODO**: ask Schnorr if there was a problem in this test. Every group seems to have gotten it wrong.
- **(4 errors)** Test files `ijk1A` and `ijk1B` (2 tests each) went wrong because we didn't deal correctly with the unary operations in lines `a = -4;` and `a = -3;`, respectively. If the expressions are changed to `a = 0 - 4` and `a = 0 - 3` both programs run correctly. That's what makes me think the problem is in unary operations.
    - ~~**TODO**: solve this in phase 6.~~ Fixed in phase 6.
- **(3 errors)** Test files `ijk22`, `ijk23` and `ijk24` went wrong for the data segment verifications (one test for each). Files `ijk22` and `ijk24` also had a stack verification each, and both were right. The problem here appears to be in saving correctly the return value of a function to the var it's attributed to.
    - ~~**TODO**: solve this in phase 6.~~ Fixed in phase 6.
- **(15 errors)** Test files `ijk25`, `ijk27`, `ijk29` and `ijk30` (which had respectively 3, 5, 5 and 2 tests) entered a loop when executed by the simulator. It seems that we miscalculated the number of instructions to be jumped over in the function call sequence.
    - ~~**TODO**: solve this in phase 6.~~ Fixed in phase 6.
- **(10 errors)** Test files `ijk26` (6 tests) and `ijk28` (4 tests) went wrong because we didn't deal with recursion in this phase (deliberately, as there would be no time to deal with it).
    - **TODO**: maybe implement recursion in phase 6? (If there is enough time...) Check video E5D3.

### Subjective evaluation — 8.17
- There was a discount because of the swapped instruction in line 580. Not sure why we were discounted exactly this much though... :thinking:

---

### Original submission message

This was the message sent in the `README.md` file when we originally submitted this phase:

> Optamos por fazer a geração do código intermediário em uma passada, ao mesmo tempo que as análises léxica, sintática e semântica. Chegamos a implementar as estruturas básicas para lidar com a representação intermediária (arquivos `ILOC.hpp` e `ILOC.cpp`) e a geração do código na linguagem ILOC para algumas estruturas da nossa linguagem (expressões aritméticas e comando de atribuição).
> Mais uma vez entregamos uma versão incompleta do código, que completaremos nos próximos dias. Acreditamos estar perto de tirar o atraso que criamos na Etapa 3, mas infelizmente ainda não conseguimos para esta etapa.