/* loading mina.pl file */
:- [mina].


/* inicio da rotina */
inicio :-
	apagaAmbiente,
	tabuleiro(Dimensao),
	montaAmbiente(1, 1, Dimensao).


/* garante que o arquivo 'ambiente.pl' está vazio */
apagaAmbiente :-
	open('ambiente.pl', write, Stream),
	write(Stream, ''), close(Stream).



/* quando, na recursão, o tamanho da coluna é ultrapassado */
montaAmbiente(L, C, TAM) :-
	L < TAM,
	C > TAM,
	Linha is L+1,
	/* escreve linha vazia */
	escreverLinhaNoAmbiente(''),
	montaAmbiente(Linha, 1, TAM).

/* quando em posição válida no tabuleiro */
/* mas há mina na casa */
/* nada é escrito */
montaAmbiente(L, C, TAM) :-
	L =< TAM,
	C =< TAM,	 
	Linha is L,
	Coluna is C,
	mina(L, C),
	Cdepois is Coluna + 1,
	montaAmbiente(Linha, Cdepois, TAM).

/* quando em posição válida no tabuleiro */
montaAmbiente(L, C, TAM) :-
	L =< TAM,
	C =< TAM,	 
	Linha is L,
	Coluna is C,
	\+mina(L, C),
	vizinhos(Linha, Coluna, N),
	atom_concat('valor(', Linha, Str),
	atom_concat(Str, ',', Str1),
	atom_concat(Str1, Coluna, Str2),
	atom_concat(Str2, ',', Str3),
	atom_concat(Str3, N, Str4),
	atom_concat(Str4, ').', Str5),
	escreverLinhaNoAmbiente(Str5),
	Cdepois is Coluna + 1,
	montaAmbiente(Linha, Cdepois, TAM).


/* Condição de parada apenas para retornar true */
montaAmbiente(L, C, TAM):-
	L = TAM,
	Estouro is TAM+1,
	C = Estouro.


/* conta minas vizinhas a uma casa */
vizinhos(L, C, N) :-
	Lantes is L-1, Ldepois is L+1,
	Cantes is C-1, Cdepois is C+1,
	verificaMina(Lantes, Cantes, N1),
	verificaMina(Lantes, C, N2),
	verificaMina(Lantes, Cdepois, N3),
	verificaMina(L, Cantes, N4),
	verificaMina(L, Cdepois, N5),
	verificaMina(Ldepois, Cantes, N6),
	verificaMina(Ldepois, C, N7),
	verificaMina(Ldepois, Cdepois, N8),
	N is (N1+N2+N3+N4+N5+N6+N7+N8).


/* retorna 1 se há mina, e 0 c.c. */
verificaMina(L, C, 1) :- mina(L, C).
verificaMina(L, C, 0) :- \+mina(L, C).


/* faz append de uma linha em 'ambiente.pl' */
escreverLinhaNoAmbiente(L) :-
	open('ambiente.pl', append, Stream), 
	write(Stream, L),  nl(Stream), 
	close(Stream).