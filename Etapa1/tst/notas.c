//calcula as notas nas disciplinas do primeiro semestre
//faltam as recuperações - vou deixar pra fazer outra hora
//faltam os conceitos

#include <stdio.h>

int main(){
    int repete = 0;
    char cadeira, calcConc, algprogConc;//, arqConc, fundConc;
    float calcT1, calcP1, calcT2, calcP2, calcArea1, calcArea2, calcFinal;
    float algprogP1, algprogP2, algprogAP, algprogTF, algprogFinal;

    //float arqV1, arqV2, arqV3, arqTN, arqTA, arqFinal;
    //float fundP1, fundP2, fundTrabs, fundFinal;

    while (repete == 0){

        printf("\nDE QUE DISCIPLINA VOCE DESEJA CALCULAR A NOTA?\n");
        printf("calculo = 1\n");
        printf("algprog = 2\n");
        printf("discreta = 3\n");
        printf("arq0 = 4\n");
        printf("fundamentos = 5\n");
        scanf(" %c", &cadeira);

        switch(cadeira)
        {
        case '1': //cálculo
            printf("\n\n***NOTA DE CALCULO***\n\n");
            printf("insira nota do T1:\n");
            scanf("%f", &calcT1);
            printf("insira nota da P1:\n");
            scanf("%f", &calcP1);
            printf("insira nota do T2:\n");
            scanf("%f", &calcT2);
            printf("insira nota da P2:\n");
            scanf("%f", &calcP2);

            calcArea1 = (0.3 * calcT1) + (0.7 * calcP1);
            printf("\nnota na area 1: %.2f\n", calcArea1);
            calcArea2 = (0.3 * calcT2) + (0.7 * calcP2);
            printf("nota na area 2: %.2f\n\n", calcArea2);

            if (calcArea1 < 4 && calcArea2 < 4){
                printf("ALUNO REPROVADO\n");
                printf("NOTA INSUFICIENTE NAS AREAS 1 E 2\n");
            } else if (calcArea1 < 4) {
                printf("ALUNO REPROVADO\n");
                printf("NOTA INSUFICIENTE NA AREA 1\n");
            } else if (calcArea2 < 4){
                printf("ALUNO REPROVADO\n");
                printf("NOTA INSUFICIENTE NA AREA 2\n");
            } else {
                calcFinal = (0.5 * calcArea1) + (0.5 * calcArea2);
                printf("NOTA FINAL EM CALCULO: %.2f\n", calcFinal);
            }

            if (calcArea1 < 4 || calcArea2 < 4 || calcFinal < 6){
                calcConc = 'D';
            } else if (calcFinal < 7.5){
                calcConc = 'C';
            } else if (calcFinal < 9){
                calcConc = 'B';
            } else if (calcFinal <= 10){
                calcConc = 'A';
            } else {
                printf("ERRO: NOTAS INVALIDAS\n");
                calcConc = '-';
            }

            printf("CONCEITO EM CALCULO: %c\n", calcConc);

            break;

        case '2': //algprog
            printf("\n\n***NOTA DE ALGPROG***\n\n");
            printf("insira nota da P1:\n");
            scanf("%f", &algprogP1);
            printf("insira nota da P2:\n");
            scanf("%f", &algprogP2);
            printf("insira nota das aulas praticas:\n");
            scanf("%f", &algprogAP);
            printf("insira nota do trabalho final:\n");
            scanf("%f", &algprogTF);

            algprogFinal = (0.3 * algprogP1) + (0.45 * algprogP2) + (0.15 * algprogAP) + (0.1 * algprogTF);
            printf("\nNOTA FINAL EM ALGPROG: %.2f\n", algprogFinal);

            if (algprogFinal < 6){
                algprogConc = 'D';
            } else if (algprogFinal < 7.5){
                algprogConc = 'C';
            } else if (algprogFinal < 8.5){
                algprogConc = 'B';
            } else if (algprogFinal <= 10){
                algprogConc = 'A';
            } else {
                printf("ERRO: NOTAS INVALIDAS\n");
                algprogConc = '-';
            }

            printf("CONCEITO EM ALGPROG: %c\n", algprogConc);

            break;

        case '3': //discreta
            /*printf("\n\n***NOTA DE DISCRETA***\n\n");
            break;*/

        case '4': //arquitetura
            //falta definir os trabalhos

            /*printf("\n\n***NOTA DE ARQ0***\n\n");
            printf("insira nota da V1:\n");
            scanf("%f", &arqV1);
            printf("insira nota da V2:\n");
            scanf("%f", &arqV2);
            printf("insira nota da V3:\n");
            scanf("%f", &arqV3);
            printf("insira nota do TN:\n");
            scanf("%f", &arqTN);
            printf("insira nota do TA:\n");
            scanf("%f", &arqTA);

            arqFinal = (0.25 * arqV1) + (0.25 * arqV2) + (0.25 * arqV3) + (0.25 * ((arqTN + 2 * arqTA)/3));
            printf("NOTA FINAL EM ARQ0: %.2f\n", arqFinal);
            break;*/

        case '5': //fundamentos
            //falta definir os trabalhos

            /*printf("\n\n***NOTA DE FUNDAMENTOS***\n\n");
            printf("insira nota da P1:\n");
            scanf("%f", &fundP1);
            printf("insira nota da P2:\n");
            scanf("%f", &fundP2);
            printf("insira nota dos trabs:\n");
            scanf("%f", &fundTrabs);

            fundFinal = (0.4 * fundP1) + (0.5 * fundP2) + (0.1 * fundTrabs);
            printf("NOTA FINAL EM FUNDAMENTOS: %.2f\n", fundFinal);*/

            printf("\n\ndisciplina indisponivel no momento, desculpe o transtorno");
            break;

        default: printf("codigo de disciplina invalido");
        }

        do {
        printf("\n\nDeseja calcular outra nota? (SIM=0, NAO=1)\n");
        scanf("%d", &repete);
        } while (repete < 0 || repete > 1);
    }
    return(0);
}
