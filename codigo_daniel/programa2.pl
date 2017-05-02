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
	escreveValor(L, C, N).

/* quando há um '0' na casa, busca recursivamente */
/* os vizinhos até achar todos os que têm valor */
posicao(L, C) :-
	valor(L, C, 0),
	escreveJogada(L,C),
	Lantes is L-1,
	Ldepois is L+1,
	Cantes is C-1,
	Cdepois is C+1,
	posicao(Lantes, Cantes),
	posicao(Lantes, C),
	posicao(Lantes, Cdepois),
	posicao(L, Cantes),
	posicao(L, Cdepois),
	posicao(Ldepois, Cantes),
	posicao(Ldepois, C),
	posicao(Ldepois, Cdepois).

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
