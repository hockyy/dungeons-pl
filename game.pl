:- use_module(library(clpfd)).

peta([[0, 0, 0],[0, 0, 0]]).
n(Self) :- peta(A), length(A, Self).
m(Self) :- peta([Head | _]), length(Head, Self).

iterator(A, B, A) :- A =< B.
iterator(A, B, X) :-
    A < B,
    Nx is A+1,
    iterator(Nx,B,X).

% https://stackoverflow.com/questions/8519203/prolog-replace-an-element-in-a-list-at-a-specified-index
replace(Index, Old, Replace, New) :-
    nth0(Index, Old, _, R),
    nth0(Index, New, Replace, R).

nth2d(List2D,X, Y, Element):- 
    nth0(X, List2D, List1D),
    nth0(Y, List1D, Element).

get_peta(X,Y,Element) :-
    is_in_grid(X,Y),
    peta(Peta),
    nth2d(Peta,X,Y,Element).

print_peta(X,Y,Position):-
    \+ is_in_grid(X,Y)->  !;
    % if
    (([X, Y] = Position) -> 
        % then
        (write(1));
        % else
        (get_peta(X, Y, Element),
        write(Element))
    ),

    move_next([X,Y], right,[Nx,Ny]),
    ((is_in_grid(Nx,Ny))->
        (print_peta(Nx,Ny,Position));

        (NextX is X+1,
        write('\n'),
        print_peta(NextX,0,Position))
    ).

print_peta(Position) :-
    print_peta(0,0,Position).
    
read_key([Code|Codes]) :-
    get_single_char(Code),
    read_pending_codes(user,Codes,[]).
 
read_keyatom(KAtom) :-
    read_key(Codes),
    codes_keyatom(Codes,KAtom).
 
codes_keyatom([119],up)    :- !.
codes_keyatom([115],down)  :- !.
codes_keyatom([100],right) :- !.
codes_keyatom([97],left)  :- !.
codes_keyatom([98], stop) :- !.
codes_keyatom(_, unknown) :- !.

direction(right,[0,1]).
direction(left,[0,-1]).
direction(down,[1,0]).
direction(up,[-1,0]).

move_next([OldX,OldY], Direction, [NextX, NextY]) :-
    direction(Direction,[DirX,DirY]),
    NextX is DirX + OldX,
    NextY is DirY + OldY.

is_in_grid(X, Y) :-
    n(N),m(M),
    0 =< X, 0 =< Y,
    X < N, Y < M.

go(X,Y) :-
    tty_clear,
    print_peta([X,Y]),
    read_keyatom(Key),
    (Key = stop -> !;
        move_next([X,Y], Key, [NextX,NextY]),
        is_in_grid(NextX,NextY)-> go(NextX,NextY);go(X,Y)
    ).

:- go(0,0).