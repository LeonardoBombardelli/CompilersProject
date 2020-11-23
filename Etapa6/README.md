# Etapa 6 — Grupo H

Nesta etapa, decidimos fazer a geração do código alvo numa segunda passada. Implementamos a função `generateAsm()` que recebe o código ILOC e o converte para Assembly. 

Tivemos problemas para traduzir corretamente os endereçamentos de elementos da pilha, devido às diferenças nos tamanhos dos dados empilhados. Por padrão, o código em Assembly x86_64 empilha dados de 8 bytes, e não traduzimos corretamente as informações referentes aos inteiros da Linguagem, que têm 4 bytes.

Além disso, tivemos um problema que não conseguimos identificar na tradução de laços `for` e `while do` de ILOC para Assembly. Pelo que testamos, o código ILOC gerado é executado corretamente no simulador, o que parece indicar que o problema não está na sua geração. Entretanto, comparando instrução a instrução os dois códigos não notamos nenhuma discrepância que explique essa diferença no comportamento.

Um último problema que não conseguimos entender ocorre quando o código na Linguagem faz uso de algum operador unário. O código alvo é gerado e nos parece executar corretamente, mas ocorre falha de segmentação ao final da execução do nosso compilador. Acreditamos que isso se deva a um acesso indevido na liberação de memória.