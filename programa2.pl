load_file :- open('mina.pl', read, Stream),
			repeat,
		    read(Stream, Line),
		    (   Line = end_of_file ->  true;   
		    	assertz(Line),
		    	fail
		    ),
		    close(Stream),
		    open('ambiente.pl', read, Stream2),
			repeat,
		    read(Stream2, Line2),
		    (   Line2 = end_of_file ->  true;   
		    	assertz(Line2),
		    	fail
		    ),
		    close(Stream2).

write_valor(X,Y):- valor(X,Y,N),
			write("valor("),
			write(X),
			write(","),
			write(Y),
			write(","),
			write(N),
			write(").\n").

posicao(X,Y):- mina(X,Y), !, write("jogo encerrado").
posicao(X,Y):- valor(X,Y,N), N>0,!, write_valor(X,Y).
posicao(X,Y):- adjacent_fields(X,Y).

adjacent_fields(X,Y):- adjacent_field_xsub1_ysub1(X,Y,[X,Y]),
						adjacent_field_xsub1_y(X,Y,[X,Y]),
						adjacent_field_xsub1_ysom1(X,Y,[X,Y]),
						adjacent_field_x_ysub1(X,Y,[X,Y]),
						adjacent_field_x_y(X,Y,[X,Y]),
						adjacent_field_x_ysom1(X,Y,[X,Y]),
						adjacent_field_xsom1_ysub1(X,Y,[X,Y]),
						adjacent_field_xsom1_y(X,Y,[X,Y]),
						adjacent_field_xsom1_ysom1(X,Y,[X,Y]).

adjacent_field_xsub1_ysub1(X,Y,L) :- Z is X-1, W is Y-1, Z>0, W>0, [Z,W]\=L, write_valor(Z,W).
adjacent_field_xsub1_ysub1(_,_,_).

adjacent_field_xsub1_y(X,Y,L) :- Z is X-1, W is Y, Z>0, [Z,W]\=L, write_valor(Z,W).
adjacent_field_xsub1_y(_,_,_).

adjacent_field_xsub1_ysom1(X,Y,L) :- Z is X-1, W is Y+1, Z>0, [Z,W]\=L, write_valor(Z,W).
adjacent_field_xsub1_ysom1(_,_,_).

adjacent_field_x_ysub1(X,Y,L) :- Z is X, W is Y-1, W>0, [Z,W]\=L, write_valor(Z,W).
adjacent_field_x_ysub1(_,_,_).

adjacent_field_x_y(X,Y,_) :- write_valor(X,Y).
adjacent_field_x_y(_,_,_).

adjacent_field_x_ysom1(X,Y,L) :- Z is X, W is Y+1, [Z,W]\=L, write_valor(Z,W).
adjacent_field_x_ysom1(_,_,_).

adjacent_field_xsom1_ysub1(X,Y,L) :- Z is X+1, W is Y-1, W>0, [Z,W]\=L, write_valor(Z,W).
adjacent_field_xsom1_ysub1(_,_,_).

adjacent_field_xsom1_y(X,Y,L) :- Z is X+1, W is Y, [Z,W]\=L, write_valor(Z,W).
adjacent_field_xsom1_y(_,_,_).

adjacent_field_xsom1_ysom1(X,Y,L) :- Z is X+1, W is Y+1, [Z,W]\=L, write_valor(Z,W).
adjacent_field_xsom1_ysom1(_,_,_).





/*adjacent_fieldx(_,_,[],_).
adjacent_fieldx(X,Y,[V|L],L2):- adjacent_fieldy(X,Y,V,L2), adjacent_fieldx(X,Y,L,L2).

adjacent_fieldy(_,_,_,[]).
adjacent_fieldy(X,Y,V,[W|L]):- Z is X+V, M is Y+W, not(and(Z=X,M=Y)), !, posicao(Z,M), adjacent_fieldy(X,Y,V,L).
adjacent_fieldy(X,Y,V,[_|L]):- valor(X,Y,N),
							write("valor("),
							write(X),
							write(","),
							write(Y),
							write(","),
							write(N),
							write(").\n"),
							adjacent_fieldy(X,Y,V,L).

and(A,B):- A, !, B.
and(A,B):- false.*/