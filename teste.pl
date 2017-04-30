sum(3).
sum(2).
sum(X+Y).

p([1,2,3]).
p([o,gato,pulou,[sobre,a,caixa]]).

l1([X,Y,Z]).
l2(john,fish,deoval).

mina(1,2).
adjacent(X,Y,V,[W|L],N,D):- Z is X+V, M is Y+W, mina(Z,M), D is N+1, adjacent(X,Y,V,L,N,D).