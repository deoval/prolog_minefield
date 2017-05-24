/** 
	Prepara os arquivos de configuracao e de saida de jogadas
	garantindo que o arquivo 'jogo_aut.pl' está vazio
*/
:-	['mina', 'ambiente'],
	open('jogo_aut.pl', write, Stream),
	write(Stream, ''), close(Stream),
	nb_setval(numJogadas, 0).


/****************************************************
	INICIO MANIPULACAO E DIRECIONAMENTO DE JOGADAS
*****************************************************/
/** 
	Comando inicial para começar a jogar
*/
jogue :- primeiraJogadaAleatoria(), jogar.

/** 
	Efetua a primeira jogada aleatoria com "posicao(X,Y)" aleatorios
	e busca possiveis minas e possiveis casas seguras
*/
primeiraJogadaAleatoria() :- 
	tabuleiro(N),
	A is N + 1,
	random(1,A,X),
	random(1,A,Y),
	posicao(X,Y), 
	verificarTodasCasasAbertasPorMinasAoRedor(),
	verificarTodasCasasAbertasPorCasasSeguras().

/** 
	Sempre que "jogar" for chamado verifica se foi definido o "fim" 
*/
jogar :- 
	current_predicate(fim/0),
	!.

/** 
	Caso não tenha definido "fim", verifica se há casa segura
	salvas com assertz, joga nela, remove com retractall e checa
	se a vitoria foi alcancada
*/
jogar :- 
	current_predicate(casaSegura/2),
	casaSegura(X,Y),
	posicao(X,Y), 
	retractall(casaSegura(X,Y)),
	verificarTodasCasasAbertasPorMinasAoRedor(),
	verificarTodasCasasAbertasPorCasasSeguras(),
	vitoria().

/** 
	Caso não tenha definido casas seguras, prepara para jogar aleatorio
*/
jogar :- 
	tabuleiro(N),
	A is N + 1,
	random(1,A,X),
	random(1,A,Y),
	jogarAleatorio(X,Y).

/** 
	Antes de jogar verifica se a casa aleatoria ja foi aberta,
	se sim verifica condicao de vitoria sem jogar ali
*/
jogarAleatorio(X,Y) :- 
	current_predicate(casaAberta/2),
	casaAberta(X,Y),
	!,
	vitoria().

/** 
	Antes de jogar verifica se a casa aleatoria é uma mina conhecida,
	se sim verifica condicao de vitoria sem jogar ali
*/
jogarAleatorio(X,Y) :- 
	current_predicate(temMina/2),
	temMina(X,Y),
	!,
	vitoria().

/** 
	Joga na casa aleatoria e depois varre todas as casas abertas
	em busca de minas e casas seguras
*/
jogarAleatorio(X,Y) :-
	posicao(X,Y), 
	verificarTodasCasasAbertasPorMinasAoRedor(),
	verificarTodasCasasAbertasPorCasasSeguras(),
	vitoria().
/****************************************************
	 FIM MANIPULACAO E DIRECIONAMENTO DE JOGADAS
*****************************************************/



/****************************************************
		 INICIO CONDICOES DE TERMINO DO JOGO
*****************************************************/
/** 
	Verifica se a condicao de vitoria não foi satisfeita para então jogar novamente.
	A codição de vitoria é se a quantidade de casas abertas é igual a quantidade
	de casas sem minas
*/
vitoria :-
	tabuleiro(N),
	qtdCasasAbertas(CasasAbertas),
	qtdMinasEncontradas(QtdMinas), 
	QtdCasas is N * N,
	QtdCasasSemMinas is QtdCasas - QtdMinas,
	CasasAbertas \= QtdCasasSemMinas,
	!,
	jogar.

/** 
	Chamado caso atinja codicao de vitoria
*/
vitoria :- 
	escreverLinhaNoJogo('/*AMBIENTE*/'),
	escreverLinhaNoJogo('vitoria'),
	write('vitoria'),
	assertz(fim).

/** 
	Chamado quando cai em uma mina
*/
jogo_encerrado :-
	escreverLinhaNoJogo('/*AMBIENTE*/'),
	escreverLinhaNoJogo('jogo encerrado'),
	write('jogo encerrado'),
	assertz(fim).
/****************************************************
		   FIM CONDICOES DE TERMINO DO JOGO
*****************************************************/



/**********************************************
	     INICIO DIRETIVAS AUXILIADORAS
***********************************************/
/** 
	Escreve o comando jogado no arquivo e no console
*/
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

/**
	Escreve valor lido no 'ambiente.pl' com titulo
*/
escreveValor(L, C, N) :-
	escreverLinhaNoJogo('/*AMBIENTE*/'),
	escreveValorPuro(L, C, N).

/**
	Escreve valor lido no 'ambiente.pl'
*/
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

/**
	Faz append de uma linha em 'jogo_aut.pl'
*/
escreverLinhaNoJogo(L) :-
	open('jogo_aut.pl', append, Stream), 
	write(Stream, L),  nl(Stream), 
	close(Stream).


/** 
	Contagem recursiva de elementos em uma lista
*/
countQtdElemLista([],0).
countQtdElemLista([_|L],R):- countQtdElemLista(L,C), R is C+1.

/** 
	Conta a quantidade de minas encontradas salvas com assertz
*/
qtdMinasEncontradas(M) :-
	findall(mina(X,Y), mina(X,Y),L),
	countQtdElemLista(L,M).

/** 
	Conta a quantidade de casas abertas salvas com assertz
*/
qtdCasasAbertas(C) :- 
	current_predicate(casaAberta/2),
	findall(casaAberta(X,Y),casaAberta(X,Y), L),  
	countQtdElemLista(L, C).

/** 
	Conta a quantidade de casas com mina ao redor de uma casa (L,C)
*/
qtdCasasComMinaAoRedor(L,C,R,[L1,L2,L3,L4,L5,L6,L7,L8]) :-
	Lantes is L-1,
	Ldepois is L+1,
	Cantes is C-1,
	Cdepois is C+1,
	casaComMina(Lantes, Cantes,R1,L1),
	casaComMina(Lantes, C,R2,L2),
	casaComMina(Lantes, Cdepois,R3,L3),
	casaComMina(L, Cantes,R4,L4), 
	casaComMina(L, Cdepois,R5,L5),
	casaComMina(Ldepois, Cantes,R6,L6),
	casaComMina(Ldepois, C,R7,L7),
	casaComMina(Ldepois, Cdepois,R8,L8),
	R is R1 + R2 + R3 + R4 + R5 + R6 + R7 + R8.

casaComMina(X,_,0,[]) :- X = 0,!.
casaComMina(_,Y,0,[]) :- Y = 0,!.
casaComMina(X,_,0,[]) :- tabuleiro(N), A is N+1, X = A,!.
casaComMina(_,Y,0,[]) :- tabuleiro(N), A is N+1, Y = A,!.
casaComMina(X,Y,0,[]) :- current_predicate(temMina/2),not(temMina(X,Y)),!.
casaComMina(X,Y,1,[X,Y]).

/** 
	Conta a quantidade de casas fechadas ao redor de uma casa (L,C)
*/
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
/**********************************************
		   FIM DIRETIVAS AUXILIADORAS
***********************************************/



/**********************************************
	INICIO ESTRATEGIA DE ACHAR CASAS SEGURAS
***********************************************/
verificarTodasCasasAbertasPorCasasSeguras():-
	current_predicate(casaAberta/2),!,
	findall([X,Y],casaAberta(X,Y), L), 
	loopVerificaCasasSeguras(L).
verificarTodasCasasAbertasPorCasasSeguras().

loopVerificaCasasSeguras([[X,Y]|L]) :- 
	verificarCasasSegurasAoRedor(X,Y),
	loopVerificaCasasSeguras(L).
loopVerificaCasasSeguras([]).

verificarCasasSegurasAoRedor(X,Y) :- 
	qtdCasasComMinaAoRedor(X,Y,QtdMinas,PosicoesMinas),	
	qtdCasasFechadasAoRedor(X,Y,_,PosicoesFechadas),
	valor(X,Y,V),
	V = QtdMinas,
	loopInsereCasaSegura(PosicoesFechadas,PosicoesMinas).	

verificarCasasSegurasAoRedor(_,_).

loopInsereCasaSegura([X|L],LCMinas):-
	X = [],!,loopInsereCasaSegura(L, LCMinas).
loopInsereCasaSegura([[X,Y]|L], LCMinas) :- not(member([X,Y],LCMinas)),!,
	assertz(casaSegura(X,Y)),loopInsereCasaSegura(L,LCMinas).
loopInsereCasaSegura([_|L],LCMinas) :- loopInsereCasaSegura(L,LCMinas).
loopInsereCasaSegura([],_).
/**********************************************
	 FIM ESTRATEGIA DE ACHAR CASAS SEGURAS
***********************************************/



/***********************************************
	INICIO ESTRATEGIA DE ACHAR MINAS PROXIMAS
************************************************/
verificarTodasCasasAbertasPorMinasAoRedor():-
	current_predicate(casaAberta/2),!,
	findall([X,Y],casaAberta(X,Y), L), 
	loopVerificaCasasComMinaAoRedor(L).
verificarTodasCasasAbertasPorMinasAoRedor().

loopVerificaCasasComMinaAoRedor([[X,Y]|L]) :- 
	verificarMinasAoRedor(X,Y),
	loopVerificaCasasComMinaAoRedor(L).
loopVerificaCasasComMinaAoRedor([]).


verificarMinasAoRedor(X,Y) :- 
	current_predicate(casaAberta/2),
	casaAberta(X,Y),
	valor(X,Y,V), 
	qtdCasasFechadasAoRedor(X,Y,C,L), 
	V = C,
	loopInsereMina(L).

verificarMinasAoRedor(_,_).

loopInsereMina([X|L]) :- 
	X = [],!,loopInsereMina(L).
loopInsereMina([[X,Y]|L]) :-
	assertz(temMina(X,Y)),loopInsereMina(L).
loopInsereMina([]).
/***********************************************
	 FIM ESTRATEGIA DE ACHAR MINAS PROXIMAS
************************************************/
 


/***********************************************
	INICIO ABERTURA DE CASAS E RECURSIVAMENTE
************************************************/
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
	escreveValorPuro(L, C, 0),
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
/***********************************************
	 FIM ABERTURA DE CASAS E RECURSIVAMENTE
************************************************/