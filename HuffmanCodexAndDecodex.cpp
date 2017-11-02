#include <iostream>
#include <string>
#include <algorithm>
#include <iomanip>
#include <stdlib.h>
#include <stdio.h>

/*
Esquema de indexação de matrizes
matriz[I][J]	I linhas
		J colunas
matriz[i][j] = matriz[i*J + j]
*/

using namespace std;


// Retorna uma única palavra código de acordo
string huffWord(
	int* huffNew, 	// Matriz das palavras código finalizada
	int _words, 	// Numero de caracteres
	int linha)	// Linha da matriz -> palavra código 
{
	int i, element;
	string palavraCodigo = "";
	for (i = _words-2; i >= 0; i--){
		element = huffNew[linha*_words + i];
		if (element == 0)
			palavraCodigo.append("0");
		if (element == 1)
			palavraCodigo.append("1");
	}
	return palavraCodigo;
}
/*
 Acrescenta a palavra código correspondente ao elemento de index 
_ordem o valor de 0 ou 1, dependendo do parâmetro bin, para uma
dada iteração do algoritmo.
Como esse elemento pode ter surgido da soma de outros dois, feita
na iteração anterior, o valor bin é na prática acrescentado a 
esses dois elementos originais. Se eles também tiverem surgido 
por uma soma, faz-se o mesmo.
O que acontece no código é:
-Na parte da soma, o maior index é dado a soma, e o menor é 
atribuido como antecessor do index maior, deixando de fazer 
parte do conjunto onde acontece as próximas somas. 
Assim, quando o valor bin é atribuido a o index que sobra, 
também será feito a seus antecessores, e aos antecessores deles,
recursivamente.
*/
void huffmanSet(
	int* _ant,	// Matriz dos antecessores 
	int _ordem, 	// Ordem do elemento
	int _words, 	// Número de elementos
	int bin, 	// 0 ou 1
	int i,		// Número da iteração
	int* huffNew)	// Matriz das palavras código
{
	int j,k;

	// Atribui bin a um dos pares que está
	// na soma do passo do algoritmo, isto é, o
	// elemento de index _ordem
	huffNew[(_words - (_ordem+1))*_words + i] = bin;

	for (j = 0; j < _words; j++){
		// Antecessores do elemento de index _ordem
		k = _ant[j*_words + _ordem];
		
		// Caso for != 0, há um antecessor, correspondente
		// ao valor k
		if (k != 0){
			// Chama a mesma função para o elemento da
			// ordem k, atribuindo-lhe o valor bin
			// e checando se ele possui antecessores
			huffmanSet(_ant, k-1, _words, bin, i, huffNew);
		}
	}
}	
				
int main(){
	string frase;
	frase = (char*) malloc (frase.size());

	cout << "Digite a frase a ser codificada:" << endl;
	getline(cin, frase);
	
	string dict = "";
	int i = 0, j = 0;
	size_t n, found;

	// Salva em dict o caractere e a seguir o número de ocorrências
	for (i = 0; i < frase.size(); i++){ 
		found = dict.find(frase[i]);
		if (found == string::npos){
			dict.append(frase, i, 1);
			n = std::count(frase.begin(), frase.end(), frase[i]);
			dict.append(1, (n+48));
		}
	}
	
	// Numero de caracteres na frase
	int words = dict.size()/2;

	float probs[words], auxProb, auxLetra, auxTroca;
	for (i = 0; i < words; i++){
		auxProb = float(dict[1 + (i*2)] - 48)/frase.size();
		for (j = 0; j < i; j++){
			/* 
			Caso o novo caráctere inserido tenha menor
			probabilidade de ocorrência na string, 
			troca consecutivamente de lugar o novos valores
			até encontrar um menor que o mesmo
			*/
			if (auxProb > probs[j]){
				// Troca de lugar as probabilidades	
				auxTroca = auxProb;
				auxProb = probs[j];
				probs[j] = auxTroca;
				
				// Troca de lugar os caracteres
				auxTroca = dict[i*2];
				dict[i*2]= dict[j*2];
				dict[j*2] = auxTroca;

				// Troca de lugar o número de ocorrências
				auxTroca = dict[i*2+1];
				dict[i*2+1]= dict[j*2+1];
				dict[j*2+1] = auxTroca;
			}
		}
		probs[i] = auxProb;
	}
 
	cout << words << " caracteres" << endl;

	/*
	No algoritmo, os valores 0 e 1 são atribuídos a cada par da soma de 
	cada iteração
	No código, a cada iteração, os 0s e 1s são atribuidos aos caracteres 
	originais, então é necessário manter um rastreio de quais desses 
	caracteres, quando somados, geram as "palavras novas", as quais 
	podemos indicar como o caractere que representa a soma
	Ex:
	a-0.6------>0.6->1
	b-0.2->1--->0.4->0
	c-0.2->0
	
	Na primeira, iteração, 1 é atribuido a "b" e 0 a "c". Na segunda, 
	1 a "a" e 0 a um novo caractere. O que o código faz é considerar 
	esse novo caractere como "b", isto é, é mantida a posição do caractere
	de maior ordem (mais alto na lista) e o outro caractere é salvo
	numa matriz que indica que ele é um antecessor desse novo caractere
	Matriz antecessores:
	c b a
	0 0 0	-> iteração 1: não há antecessores
	0 1 0	-> iteração 2: b tem um antecessor, o primeiro elemento da lista
			       de caracteres, isto é, "c"

	Assim, quando 1 ou 0 é atribuido a um caractere, checa-se se este não 
	possui antecessores. Se as coluna for composta apenas de 0s, não há
	antecessor, e essa é a primeira vez que o caractere é "somado"
	Se sim, esse caractere, é na verdade uma soma de outros dois, que são:
	o caractere cuja posição é a coluna, isto é, a n-esima coluna representa
	-o n-esimo elemento contando a partir de do de menor probabilidade.
	-o elemento, da posição correspondente a esse valor não zero.
	Essa busca é feita de forma iterativa: ao se checar o segundo elemento,
	procura-se saber se ele não possui antecessores, indicando que ele mesmo
	já era na verdade uma soma que ocorreu numa iteração passada.
	Dessa forma, a cada iteração, os 0s e 1s são adicionados em todas as 
	palavras códigos que "convergem" nos pares somados.

	É por meio do vetor ordem[words], sabemos onde estão cada elemento
	Como visto anteriormente, na soma, o caractere de maior probabilidade
	"vira" o resultado da soma, que pode assumir uma nova posição para 
	manter a ordem crescente. Quando essa mudança é feita, troca-se os 
	valores dos elementos do vetor ordem, a fim de guardar essa mudandança
	
	Para cada iteração, as palavras códigos vão sendo definidas
	A matriz huffNew words x words-1 indica as palavras código
	Ela começa cheia de 8s e cada linha corresponde a uma palavra código
	e cada coluna corresponde a uma iteração.
	Dependendo de a quais palavras são acrescentados 0s e 1s às respectivas
	palavras código, os valores de uma coluna são mudados.
	Ou seja, a cada iteração (coluna), as palavras (linhas) vão crescendo
	(Raciocine os 8s como espaços vazios)

	Ex: peixe
									Antecessores:	Palavras código:
	x	i	p	e	-> Caracteres			x i p e		e 8 8 8 
	1 	2 	3 	4  	-> Ordem dos caracteres		0 0 0 0		p 8 8 8 
	0.2	0.2	0.2	0.4	-> Probabilidades		0 1 0 0		i 1 8 8 
									0 0 0 0		x 0 8 8 
									0 0 0 0 

		p	i*	e	-> Caracteres			x i p e		e 8 8 8 
	0	3	2	4	-> Ordem dos caracteres		0 0 0 0 	p 8 0 8 
	0	0.2	0.4	0.4	-> Probabilidades		0 1 0 0		i 1 1 8 
									0 0 2 0 	x 0 1 8 
									0 0 0 0 
		
			e	p*	-> Caracteres			x i p e		e 8 8 0
	0	0	4	3	-> Ordem dos caracteres		0 0 0 0 	p 8 0 1
	0	0	0.4	0.6	-> Probabilidades		0 1 0 0		i 1 1 1
									0 0 2 0		x 0 1 1
									0 0 0 3


	Notar que a matriz de antecessore possui dimensões words x words apenas por 
	se facilitar a última iteração, isto é, ter uma linha a mais para salvar os
	valores de antecessores que não serão usados, pois cada loop configura a 
	linha abaixo para a utilização pela próxima iteração

	Temos então: 	e	0
			p	10
			i	111
			x	110

	*/

	int antecessores[words*words]; 
	int ordem[words];
	int *huffNew; huffNew = (int*) calloc (words*(words-1),sizeof(int));
	// As palabras códigos são salvas numa matriz words x words-1

	int max,min;
	float  probsNew[words], probSoma;

	// Inicialização das variáveis
	for (i = 0; i < words; i++){
		for (j = 0; j < words-1; j++){
			huffNew[i*words + j] = 8;
		}
	}

	for (i = 0; i < words; i++){
		for (j = 0; j < words; j++){
			antecessores[i*words + j] = 0;
		}
		ordem[i] = i;
		probsNew[i] = probs[words-(i+1)];
	}

	// Algoritmo
	/* 
	Existem no algoritmo um total de (words-1) iterações
	Em cada iteração, valores 0 e 1 são atribuidos ao par de
	palavras cujas probabilidades estão sendo somadas, isto é,
	caso for a probabilidade original de uma das palavras, 
	atribui o 0 (ou 1) a sua respectiva palavra código formada, e
	se for uma soma de outras prob advinda de iterações anteriores,
	acrescenta o 0 (ou 1) a todas as palavras códigos das palavras
	que foram "somadas" para chegar a esse valor de probabilidade
	somado no iteração atual
	*/
	
	for (i = 0; i < (words - 1); i++){
		/*
		No começo de cada iteração, os valores das probabilidades
		estão sempre em ordem crescente, de modo que o valor 0 é
		atribuido a palavra (ou as palavras que forma essa nova)
		de indice i, e 1 a de indice i+1
		*/	

		// Atribui os valores de 0 ou 1
		huffmanSet(
			antecessores, 
			ordem[i],
			words,
			0,
			i,
			huffNew);

		huffmanSet(
			antecessores, 
			ordem[i+1],
			words,
			1,
			i,
			huffNew);

		/*
		Com as 2 últimas probabilidades do vetor probsNew 
		sempre sendo somadas, o resultado é posto no índice i+1. 
		Assim, na próxima iteração, são usadas os valores de 
		probabilidade de i+1 e i+2
		*/

		// Atualiza os valores para próxima iteração, já pondo 
		 
		probsNew[i+1] = probsNew[i] + probsNew[i+1];
		probsNew[i] = 0;

		/*
		O valores do vetor ordem guardam os índices dos caracteres
		de acordo com a ordem de ocorrência deles.
		A cada iteração, somam-se os dois últimos caracteres.
		A ordem do de maior probabilidade é mantida, enquanto
		a do de menor é passada a matriz antecessores
		*/
		max = (ordem[i] < ordem[i+1]) ? ordem[i+1] : ordem[i];
		min = (ordem[i+1] < ordem[i]) ? ordem[i+1] : ordem[i];
		antecessores[(i+1)*words + max] = min + 1;

		// Como visto, o valor
		ordem[i+1] = max;
		ordem[i] = 0;
		
		// Ordena após a soma
		/*
		A nova palavra (probabilidade, resultado da soma)
		é alocada para a nova posição de forma crescente
		O valor de ordem[i+1] também vai será trocado, de 
		modo a saber para onde a palavra formada vai
		*/
		for (j = i+1; j < (words - 1); j++){ 
			// Novo valor é maior do que o próximo
			if (probsNew[j] > probsNew[j+1]){
				auxTroca = probsNew[j+1];
				probsNew[j+1] = probsNew[j];
				probsNew[j] = auxTroca;

				// Sempre pegar o maior valor
				// da ordem nas somas
				auxTroca = ordem[j+1];
				ordem[j+1] = ordem[j];
				ordem[j] = auxTroca;				
			}
			// Caso não seja, não vai ser maior que nenhum 
			// dos próximos, pois já estão em ordem crescente
			else
				break;
		}
	}


	int fraseCodedSize = 0;
	
	for (i=0; i < frase.size(); i++){
		j = dict.find(frase[i])/2;
		fraseCodedSize = fraseCodedSize + huffWord(huffNew, words, j).size();
	}

	// Gera um vetor char que representa a frase codificadada
	char fraseCoded[fraseCodedSize];
	int pointer, linha, element;
	pointer = 0;

	for (i=0; i<frase.size(); i++){
		// Acha qual é a palavra código
		// salva como a linha da matriz huffNew
		linha = dict.find(frase[i])/2;
		// Varre a linha, acrescentando os 0s e 1s
		// a frase codificada de acordo com a 
		// palavra código que esta sendo lida no momento
		for (j = words-2; j >= 0; j--){
			element = huffNew[linha*words + j];
		
			if (element == 0){
				fraseCoded[pointer] = '0';
				pointer++;
			}	
			if (element == 1){
				fraseCoded[pointer] = '1';
				pointer++;
			}
		}
	}

	// Printa na tela as letras, as ocorrências, as probabilidades
	// e as palavras código
	cout << std::fixed;
	cout << std::setprecision(6);
	for (i = 0; i < words; i++){
		cout << dict[i*2] << "\t" 
		<< dict[1 + (i*2)] - 48 << "\t"
		<< probs[i] << "\t" 
		<< huffWord(huffNew, words, i) << "\t"
		<< huffWord(huffNew, words, i).size()
		<< endl;
	}

	// Printa a frase codificada
	for (i=0; i<fraseCodedSize; i++){
		cout << fraseCoded[i];
	}
	cout << endl;
	cout << "Tamanho da frase cod: " << fraseCodedSize << endl;
	

/*
--------------------------DECODIFICAÇÃO------------------------------


Na parte da decodificação, assumi-se que um sistema que utilize
esse tipo de código tem como variáveis para a decodificação:
huffNew
dict
words
fraseCoded
fraseCodedSize

A matriz huffNew, uma vez que todo o código é salvo nessa 
variável (vetor), e dict, que contém os caracteres. 
tendo dict, é natural que se tenha words

Os testes são feitos analisando letra por letra (0s e 1s) da
frase codificada.
Ao pegar uma letra, compara-se com as primeiras letras de cada
palavra código. Caso não ache a palavra código, testa-se a 
segunda letra da frase com a segunda de cada palavra código e 
assim por diante, até achá-la.
Então, testa-se a próxima letra da frase com a primeira de cada
palavra código novamente, repetindo o processo.

Existem então dois vetores para auxiliar essa tarefa:
	
seletor:	Seleciona quais palavras codigos ainda 
		estão sendo testadas.
		Caso não haja match, essa palavra já está 
		comprometida, e o valor do seletor correspondente
		a ela vira 0, de modo que não voltará a ser 
		analisada

testeSizes:	Quando o caractere da fraseCoded testado
		é igual a um dos números da palavra 
		codigo testada, aumenta-se o valor do vetor
		testeSizes correspondente a posição da
		da palavra código.
		Quando uma desses valores atinge o mesmo
		valor do tamanho da palavra-código, é 
		por que todos os valores testados bateram
		com a todos os valores da palavra-código
		acertada.
		Nesse caso, todos os valores do seletor voltam a 1
		e todos do testeSizes a 0, para iniciar a nova busca

palavra cod: 	         1 2 ... n
seletor	inicial:        [1 1 ... 1]	
testeSizes inicial:     [0 0 ... 0]

*/
	int seletor[words], testeSizes[words];
	for (i=0; i<words; i++){
		seletor[i] = 1;
		testeSizes[i] = 0;
	}
	// Pega a palavra código testada no momento
	string teste;
	
	// K indica a (k+1)-ésima letra testada de uma 
	// palavra código.
	int k = 0;

	// usado apenas para laços
	int kk;

	// Aponta para o vetor de char da frase decodificada
	pointer = 0;

	// Este tamanho é apenas uma estimativa com margem
	// devido aos diversos erros de memória surgidos no testes
	char fraseDecoded[fraseCodedSize];
	int fraseDecodedSize = 0;

	// Laço i: varre a frase codificada
	for (i=0; i<fraseCodedSize; i++){

		// Laço j: cada laço faz os testes com cada palavra código
		for (j=0; j<words; j++){
			// Pega a j-ésima palavra código
			teste = huffWord(huffNew, words, j);

			// Se o seletor está ativado
			if(seletor[j]){
				// Se a (i+1)-ésima letra da frase codificada
				// não casou com a (k+1)-ésima letra da 
				// (j+1)-ésima palavra código
				if(fraseCoded[i] != teste[k]){
					// Desativa seletor da (j+1)-ésima palavra código
					seletor[j] = 0;
				}
				// Se casou
				if(fraseCoded[i] == teste[k]){
					// Aumenta testeSizes, indicando que possa ser 
					// essa a palavra-código correta
					testeSizes[j]++;
					// Caso realmente seja
					if(testeSizes[j] == teste.size()){
						fraseDecodedSize++;
						// Atribui o valor da respectiva letra
						fraseDecoded[pointer] = dict[j*2];
						// Aponta para a próxima casa a receber
						// uma letra
						pointer++;
						// Zera k, de modo que o próximo teste
						// voltará a testar a partir da primeira
						// letra de cada palavra código 
						k = 0;
						// reseta seletor e testeSizes
						for (kk=0; kk<words; kk++){
							seletor[kk] = 1;
							testeSizes[kk] = 0;
						}
						// Para esse laço para já testar a próxima
						// letra da frase codificada, se houver
						break;
					}		
				}
			}
			// Caso todos as palavras códigos foram testadas, mas ainda
			// não foi encontrada qual a certa
			if (j == words-1)
				// Então, será analisado a próxima letra de cada
				// palavra código cujo seletor ainda é 1
				k++;			
		
		}
	}

	for (i=0; i<fraseDecodedSize; i++)
		cout << fraseDecoded[i];
	cout << endl;
}	
