:-	['mina', 'ambiente'],
	/* garante que o arquivo 'jogo.pl' está vazio */
	open('jogo.pl', write, Stream),
	write(Stream, ''), close(Stream),
	nb_setval(numJogadas, 0).


/* se há uma mina, encerra o jogo */
posicao(L, C) :-
	mina(L, C),
	escreveJogada(L,C),
	jogo_encerrado.

/* se há um número (!= 0) escreve o valor */
posicao(L, C) :-
	valor(L, C, N),
	N \= 0,
	escreveJogada(L,C),
	escreveValor(L, C, N),
	assertz(casaAberta(L,C)).

/* quando há um '0' na casa, busca recursivamente */
/* os vizinhos até achar todos os que têm valor */
posicao(L, C) :-
	valor(L, C, 0),
	escreveJogada(L,C),
	escreverLinhaNoJogo('/*AMBIENTE*/'),
	posicao_recursiva(L, C, [], _).

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
	escreveValorPuro(L, C, N),
	retractall(casaAberta(L,C)),
	assertz(casaAberta(L,C)).

/* quando nenhum valor é encontrado prossegue recursão */
posicao_recursiva(L, C, Visitados, NovoVisitados):-
	append([(L,C)], Visitados, Visitados2),
	valor(L, C, 0),
	escreveValorPuro(L, C, 0), /* é mesmo pra imprimir? */
	retractall(casaAberta(L,C)),
	assertz(casaAberta(L,C)),
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

escreveValorPuro(L, C, _) :- current_predicate(casaAberta/2), casaAberta(L,C).
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
	write('jogo encerrado').

/* faz append de uma linha em 'jogo.pl' */
escreverLinhaNoJogo(L) :-
	open('jogo.pl', append, Stream), 
	write(Stream, L),  nl(Stream), 
	close(Stream).


test(0, Li, [(0,1)|Li]).
test(N, Li, Lf):-
	N>0,
	append([N], Li, L),
	X is N-1,
	test(X,L,Lf).