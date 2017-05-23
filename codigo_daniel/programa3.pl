:-	['mina', 'ambiente'],
	/* garante que o arquivo 'jogo.pl' está vazio */
	open('jogo_aut.pl', write, Stream),
	write(Stream, ''), close(Stream),
	nb_setval(numJogadas, 0).

jogue :- jogarFirstAleatorio(), jogar.

jogar :- current_predicate(fim/0),!.
jogar :- jogarAleatorio().

/*TODO tornar numeros 1,6 e 25 em variaveis lidas dos arquivos.*/
jogarFirstAleatorio() :- random(1,6,X), random(1,6,Y), posicao(X,Y).

jogarAleatorio() :- random(1,6,X), random(1,6,Y),
					current_predicate(casaAberta/2), not(casaAberta(X,Y)),
					current_predicate(temMina/2), not(temMina(X,Y)), posicao(X,Y), jogar.

jogarAleatorio() :- random(1,6,X), random(1,6,Y),
					current_predicate(casaAberta/2), not(casaAberta(X,Y)), posicao(X,Y), jogar.

/*TODO O 25 tem que ser subtraido do número de minas*/
jogarAleatorio() :- tabuleiro(N), qtdCasasAbertas(C), qtdMinas(M), 
					NCasas is N * N, SMinas is NCasas - M, C < SMinas, !, jogar.

jogarAleatorio() :- win(). 

win() :- print('vitória').

qtdMinas(M) :- findall(mina(X,Y),mina(X,Y),L), countQtdElemLista(L,M).

qtdCasasAbertas(C) :- 
	current_predicate(casaAberta/2),
	findall(casaAberta(X,Y),casaAberta(X,Y), L),  
	countQtdElemLista(L, C).

countQtdElemLista([],0).
countQtdElemLista([_|L],R):- countQtdElemLista(L,C), R is C+1.


verificarVizinhos(L,C) :-  
	Lantes is L-1,
	Ldepois is L+1,
	Cantes is C-1,
	Cdepois is C+1,
	verificaVizinhosComMina(Lantes, Cantes),
	verificaVizinhosComMina(Lantes, C),
	verificaVizinhosComMina(Lantes, Cdepois),
	verificaVizinhosComMina(L, Cantes), 
	verificaVizinhosComMina(L, Cdepois),
	verificaVizinhosComMina(Ldepois, Cantes),
	verificaVizinhosComMina(Ldepois, C),
	verificaVizinhosComMina(Ldepois, Cdepois),	
	verificaVizinhosComMina(L, C).	

verificaVizinhosComMina(X,Y) :- 
	current_predicate(casaAberta/2),
	casaAberta(X,Y),
	valor(X,Y,V), 
	qtdCasasFechadasAoRedor(X,Y,C,L), 
	V = C,
	loopInsereMina(L).

verificaVizinhosComMina(_,_).

loopInsereMina([X|L]) :- 
	X = [],!,loopInsereMina(L).
loopInsereMina([[X,Y]|L]) :-
	assertz(temMina(X,Y)),loopInsereMina(L).
loopInsereMina([]).

qtdCasasFechadasAoRedor(L,C,R,[L1,L2,L3,L4,L5,L6,L7,L8]) :-
	Lantes is L-1,
	Ldepois is L+1,
	Cantes is C-1,
	Cdepois is C+1,
	casaFechada(Lantes, Cantes, R1,L1),
	casaFechada(Lantes, C, R2,L2),
	casaFechada(Lantes, Cdepois, R3,L3),
	casaFechada(L, Cantes, R4,L4),
	casaFechada(L, Cdepois, R5,L5),
	casaFechada(Ldepois, Cantes, R6,L6),
	casaFechada(Ldepois, C, R7,L7),
	casaFechada(Ldepois, Cdepois, R8,L8),
	R is R1 + R2 + R3 + R4 + R5 + R6 + R7 + R8.

casaFechada(X,_,0,[]) :- X = 0,!.
casaFechada(_,Y,0,[]) :- Y = 0,!.
casaFechada(X,_,0,[]) :- tabuleiro(N), A is N+1, X = A,!.
casaFechada(_,Y,0,[]) :- tabuleiro(N), A is N+1, Y = A,!.
casaFechada(X,Y,0,[]) :- current_predicate(casaAberta/2),casaAberta(X,Y),!.
casaFechada(X,Y,1,[X,Y]).
 
/* se há uma mina, encerra o jogo */
posicao(L, C) :-
	mina(L, C),
	escreveJogada(L,C),
	jogo_encerrado.

/* se há um número (!= 0) escreve o valor */
posicao(L, C) :-
	valor(L, C, N),
	N \= 0,
	assertz(casaAberta(L,C)),
	verificarVizinhos(L,C),
	escreveJogada(L,C),	
	escreveValor(L, C, N).

/* quando há um '0' na casa, busca recursivamente */
/* os vizinhos até achar todos os que têm valor */
posicao(L, C) :-
	valor(L, C, 0),
	/*assertz(casaAberta(L,C)), */
	escreveJogada(L,C),
	escreverLinhaNoJogo('/*AMBIENTE*/'),
	posicao_recursiva(L, C, [], _),
	verificarVizinhos(L,C).

/* quando estrapola a linha não dá erro */
posicao(L, _) :- 
	tabuleiro(N),
	L > N.
posicao(L, _) :- L=<0.

/* quando estrapola a coluna também não dá erro */
posicao(_, C) :- 
	tabuleiro(N),
	C > N.
posicao(_, C) :- C=<0.


/* CONSULTA RECURSIVA */
/* Se a casa já foi recursivamente visitada nada é feito */
posicao_recursiva(L, C, Visitados, Visitados):-
	member((L,C), Visitados).

/* quando estrapola a linha não dá erro */
posicao_recursiva(L, _, Visitados, Visitados) :- 
	tabuleiro(N),
	L > N.
posicao_recursiva(L, _, Visitados, Visitados) :- L=<0.

/* quando estrapola a coluna também não dá erro */
posicao_recursiva(_, C, Visitados, Visitados) :- 
	tabuleiro(N),
	C > N.
posicao_recursiva(_, C, Visitados, Visitados) :- C=<0.

/* quando um valor é encontrado não propaga a recursão */
posicao_recursiva(L, C, Visitados, [(L,C)|Visitados]):-
	valor(L, C, N),
	N \= 0,
	assertz(casaAberta(L,C)),
	escreveValorPuro(L, C, N).

/* quando nenhum valor é encontrado prossegue recursão */
posicao_recursiva(L, C, Visitados, NovoVisitados):-
	append([(L,C)], Visitados, Visitados2),
	valor(L, C, 0),
	assertz(casaAberta(L,C)),
	escreveValorPuro(L, C, 0), /* é mesmo pra imprimir? */
	Lantes is L-1,
	Ldepois is L+1,
	Cantes is C-1,
	Cdepois is C+1,
	posicao_recursiva(Lantes, Cantes, Visitados2, Visitados3),
	posicao_recursiva(Lantes, C, Visitados3, Visitados4),
	posicao_recursiva(Lantes, Cdepois, Visitados4, Visitados5),
	posicao_recursiva(L, Cantes, Visitados5, Visitados6),
	posicao_recursiva(L, Cdepois, Visitados6, Visitados7),
	posicao_recursiva(Ldepois, Cantes, Visitados7, Visitados8),
	posicao_recursiva(Ldepois, C, Visitados8, Visitados9),
	posicao_recursiva(Ldepois, Cdepois, Visitados9, NovoVisitados).




/* escreve o comando dado pelo usuário */
escreveJogada(L, C) :-
	nb_getval(numJogadas, N),
	NovoNumJogadas is N+1,
	nb_setval(numJogadas, NovoNumJogadas),
	atom_concat('\n/*JOGADA ', NovoNumJogadas, Str),
	atom_concat(Str, '*/', Str1),
	escreverLinhaNoJogo(Str1),
	atom_concat('posicao(', L, Str2),
	atom_concat(Str2, ',', Str3),
	atom_concat(Str3, C, Str4),
	atom_concat(Str4, ').', Str5),
	escreverLinhaNoJogo(Str5).

/* escreve valor lido no 'ambiente.pl' */
escreveValor(L, C, N) :-
	escreverLinhaNoJogo('/*AMBIENTE*/'),
	escreveValorPuro(L, C, N).

escreveValorPuro(L, C, N) :-
	atom_concat('valor(', L, Str),
	atom_concat(Str, ',', Str1),
	atom_concat(Str1, C, Str2),
	atom_concat(Str2, ',', Str3),
	atom_concat(Str3, N, Str4),
	atom_concat(Str4, ').', Str5),
	escreverLinhaNoJogo(Str5),
	write(Str5),
	write('\n').


jogo_encerrado :-
	escreverLinhaNoJogo('/*AMBIENTE*/'),
	escreverLinhaNoJogo('jogo encerrado'),
	write('jogo encerrado'),
	assertz(fim).

/* faz append de uma linha em 'jogo.pl' */
escreverLinhaNoJogo(L) :-
	open('jogo_aut.pl', append, Stream), 
	write(Stream, L),  nl(Stream), 
	close(Stream).
