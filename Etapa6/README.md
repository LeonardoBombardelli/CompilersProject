# Etapa6

**Late submission**: there is a 20% discount as we submitted this phase late, so the grades are respectively... (The current grades are what we got in the original submission. **TODO**: update here afterthe new submission)

### Objective evaluation — 3.4 (12 out of 35 tests)
- (No test files revealed until recorrection...)
#### Problems (those we knew of when we first submitted)
- This may not actually be a problem but one thing we spent some time thinking about is the fact that x86_64 Assembly stacks data in 8-byte blocks. As our data type (integer) has only 4 bytes, we might need to do a conversion sometimes.
- Need to check what's happening with `for` and `while do` loops. The ILOC code seems to be correct (as run in `ilocsim.py`) so the problem should be in the Assembly translation...
- ~~Last problem doesn't really affect the execution. It's a memory-related problem that happens with unary expressions... Need to check the semantic rule in `parser.y`.~~
    - Fixed in second try. The problem was we weren't actually copying the data from one node to the other, only attributing the same data — so we ended up with double frees when deallocating the data.

### Subjective evaluation — 6.15
- We know he takes the objective grade in consideration for the subjective evaluation. Also, we didn't put that much effort in organizing and documenting the code this time...

---

### Original submission message

This was the message sent in the `README.md` file when we originally submitted this phase:

> Nesta etapa, decidimos fazer a geração do código alvo numa segunda passada. Implementamos a função `generateAsm()` que recebe o código ILOC e o converte para Assembly. 
> Tivemos problemas para traduzir corretamente os endereçamentos de elementos da pilha, devido às diferenças nos tamanhos dos dados empilhados. Por padrão, o código em Assembly x86_64 empilha dados de 8 bytes, e não traduzimos corretamente as informações referentes aos inteiros da Linguagem, que têm 4 bytes.
> Além disso, tivemos um problema que não conseguimos identificar na tradução de laços `for` e `while do` de ILOC para Assembly. Pelo que testamos, o código ILOC gerado é executado corretamente no simulador, o que parece indicar que o problema não está na sua geração. Entretanto, comparando instrução a instrução os dois códigos não notamos nenhuma discrepância que explique essa diferença no comportamento.
> Um último problema que não conseguimos entender ocorre quando o código na Linguagem faz uso de algum operador unário. O código alvo é gerado e nos parece executar corretamente, mas ocorre falha de segmentação ao final da execução do nosso compilador. Acreditamos que isso se deva a um acesso indevido na liberação de memória.