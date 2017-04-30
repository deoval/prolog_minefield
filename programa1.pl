load_file :- open('mina.pl', read, Stream),
			repeat,
		    read(Stream, Line),
		    (   Line = end_of_file ->  true;   
		    	assertz(Line),
		    	fail
		    ),
		    close(Stream).

write_file :- open('ambiente.pl', write, Stream),
			write(Stream, "/*valor(linha,coluna,n): existem n minas adjacentes a posição (linha,coluna)*/\n"),
			close(Stream),
			tabuleiro(X),
			get_nlist(X,1,L),
			set_linex(L,L).

get_nlist(N,I,[X|L]):- I =< N,!, X is I, Y is I+1, get_nlist(N,Y,L).  
get_nlist(N,I,[]):- I > N.

set_linex([],_).
set_linex([X|L],L2) :- set_value_for_linex(X,L2), 
					open('ambiente.pl', append, Stream),
					write(Stream, "\n"),
					close(Stream),
					set_linex(L,L2).
/*Nessa parte será feito o cálculo das bombas ao redor que será colocado no lugar deste 1*/
set_value_for_linex(_,[]).
set_value_for_linex(X,[Y|L]):- adjacents_mina(X,Y,N),
							N >= 0,!,
							write_line(X,Y,N),  
							set_value_for_linex(X,L). 
set_value_for_linex(X,[_|L]):- set_value_for_linex(X,L).

write_line(Linha, Coluna, N) :- open('ambiente.pl', append, Stream),
			write(Stream, "valor("),
			write(Stream, Linha),
			write(Stream, ","),
			write(Stream, Coluna),
			write(Stream, ","),
			write(Stream, N),
			write(Stream, ").\n"),
			close(Stream).

adjacents_mina(X,Y,N):- mina(X,Y),!, N is -1.
adjacents_mina(X,Y,N8):- adjacent_field_xsub1_ysub1(X,Y,0,N1),
						adjacent_field_xsub1_y(X,Y,N1,N2),
						adjacent_field_xsub1_ysom1(X,Y,N2,N3),
						adjacent_field_x_ysub1(X,Y,N3,N4),
						adjacent_field_x_ysom1(X,Y,N4,N5),
						adjacent_field_xsom1_ysub1(X,Y,N5,N6),
						adjacent_field_xsom1_y(X,Y,N6,N7),
						adjacent_field_xsom1_ysom1(X,Y,N7,N8).

adjacent_field_xsub1_ysub1(X,Y,M,N) :- Z is X-1, W is Y-1, mina(Z,W), !, N is M+1.
adjacent_field_xsub1_ysub1(_,_,M,N) :- N is M.

adjacent_field_xsub1_y(X,Y,M,N) :- Z is X-1, W is Y, mina(Z,W), !, N is M+1.
adjacent_field_xsub1_y(_,_,M,N) :- N is M.

adjacent_field_xsub1_ysom1(X,Y,M,N) :- Z is X-1, W is Y+1, mina(Z,W), !, N is M+1.
adjacent_field_xsub1_ysom1(_,_,M,N) :- N is M.

adjacent_field_x_ysub1(X,Y,M,N) :- Z is X, W is Y-1, mina(Z,W), !, N is M+1.
adjacent_field_x_ysub1(_,_,M,N) :- N is M.

adjacent_field_x_ysom1(X,Y,M,N) :- Z is X, W is Y+1, mina(Z,W), !, N is M+1.
adjacent_field_x_ysom1(_,_,M,N) :- N is M.

adjacent_field_xsom1_ysub1(X,Y,M,N) :- Z is X+1, W is Y-1, mina(Z,W), !, N is M+1.
adjacent_field_xsom1_ysub1(_,_,M,N) :- N is M.

adjacent_field_xsom1_y(X,Y,M,N) :- Z is X+1, W is Y, mina(Z,W), !, N is M+1.
adjacent_field_xsom1_y(_,_,M,N) :- N is M.

adjacent_field_xsom1_ysom1(X,Y,M,N) :- Z is X+1, W is Y+1, mina(Z,W), !, N is M+1.
adjacent_field_xsom1_ysom1(_,_,M,N) :- N is M.

inicio :- load_file, write_file.

/*
Código antigo que eu tinha feito para calcular minas adjacentes, só que me enrolei com a variável
que iria ser o contador e resolvi fazer 1 de cada vez e nada automático. Mesmo fazendo um de cada vez
tive que usar 8 variáveis diferentes, então acho que essa abordagem não iria funcionar. Vê aí Josh
adjacents_mina(X,Y,N):- mina(X,Y),!, N is -1.
adjacents_mina(X,Y,N):- adjacent_field_mina(X,Y,N).

adjacent_field_mina(X,Y,N):- adjacent_fieldx(X,Y,[-1,0,1],[-1,0,1],N).
adjacent_field_mina(_,_,N):- N is 0.

adjacent_fieldx(_,_,[],_,_).
adjacent_fieldx(X,Y,[V|L],L2,N):- adjacent_fieldy(X,Y,V,L2,N,D), adjacent_fieldx(X,Y,L,L2,D), N is D.

adjacent_fieldy(_,_,_,[],_,_).
adjacent_fieldy(X,Y,V,[W|L],N,D):- Z is X+V, M is Y+W, mina(Z,M),!, D is 1, adjacent_fieldy(X,Y,V,L,D,D).
adjacent_fieldy(X,Y,V,[_|L],N,D):- adjacent_fieldy(X,Y,V,L,N,D).*/