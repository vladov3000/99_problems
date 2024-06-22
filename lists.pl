my_last(X, [X]).
my_last(X, [_ | T]) :- my_last(X, T).

last_but_one(X, [X, _]).
last_but_one(X, [_ | T]) :- last_but_one(X, T).

element_at(X, [X | _], 1).
element_at(X, [_ | T], K) :- N is K - 1, element_at(X, T, N).

count(0, []).
count(M, [_ | T]) :- count(N, T), M is N + 1.

my_reverse(A, A, []).
my_reverse(X, A, [H | T]) :- my_reverse(X, [H | A], T).
my_reverse(X, Y) :- my_reverse(X, [], Y).

palindrome(X) :- reverse(X, X).

my_flatten([], []).
my_flatten([H | T], Y) :-
    my_flatten(T, FT),
    (is_list(H) -> my_flatten(H, FH), append(FH, FT, Y);
     Y = [H | FT]).

compress([], []).
compress([H | T], Y) :-
    T = [H | _] -> compress(T, Y);
    compress(T, YT), Y = [H | YT].

pack([], []).
pack([H | T], Y) :-
    T = [H | _] -> pack(T, [YH | YT]), Y = [[H | YH] | YT];
    pack(T, YT), Y = [[H] | YT].

encode(X, Y) :- pack(X, P), encode_packed(P, Y).
encode_packed([], []).
encode_packed([H | T], [YH | YT]) :-
    count(N, H), [E | _] = H, YH = [N, E], encode_packed(T, YT).

encode_modified(X, Y) :- pack(X, P), encode_packed_modified(P, Y).
encode_packed_modified([], []).
encode_packed_modified([H | T], [YH | YT]) :-
    encode_packed_modified(T, YT),
    (H = [YH]; count(N, H), [E | _] = H, YH = [N, E]).

repeat(0, _, []).
repeat(N, X, [X | YT]) :- M is N - 1, repeat(M, X, YT).

decode([], []).
decode([H | T], Y) :-
    decode(T, YT),
    (H = [N, E] -> repeat(N, E, ES), append(ES, YT, Y);
     Y = [H | YT]).

encode_direct([], []).
encode_direct([H | T], Y) :-
    encode_direct(T, X),
    (X = [[N, H] | XT] -> M is N + 1, Y = [[M, H] | XT];
     X = [H | XT] -> Y = [[2, H] | XT];
     Y = [H | X]).

dupli([], []).
dupli([H | T], [H | [H | Y]]) :- dupli(T, Y).

dupli([], _, []).
dupli([H | T], N, Y) :- repeat(N, H, YH), dupli(T, N, YT), append(YH, YT, Y).

drop([], _, _, []).
drop([_ | T], N, 1, Y) :- drop(T, N, N, Y).
drop([H | T], N, I, [H | Y]) :- J is I - 1, drop(T, N, J, Y).
drop(X, N, Y) :- drop(X, N, N, Y).

split(X, 0, [], X).
split([H | T], N, [H | YT], Z) :- M is N - 1, split(T, M, YT, Z).

slice([X | _], I, I, [X]).
slice([H | T], 1, K, [H | Y]) :- K1 is K - 1, slice(T, 1, K1, Y).
slice([_ | T], I, K, Y)       :- I1 is I - 1, K1 is K - 1, slice(T, I1, K1, Y).

rotate(X, N, Y) :-
    (N < 0 -> length(X, NX), N1 is NX + N; N1 is N),
    split(X, N1, XH, XT),
    append(XT, XH, Y).

remove_at(H, [H | T], 1, T).
remove_at(X, [H | T], K, [H | R]) :- K1 is K - 1, remove_at(X, T, K1, R).

insert_at(E, X, 1, [E | X]).
insert_at(E, [H | T], K, [H | L]) :- K1 is K - 1, insert_at(E, T, K1, L).

range(A, A, [A]).
range(A, B, [A | X]) :- A1 is A + 1, range(A1, B, X).

rnd_select(_, 0, []).
rnd_select([X], 1, [X]).
rnd_select(X, N, [LH | LT]) :-
    length(X, NX),
    random(1, NX, I),
    remove_at(LH, X, I, XR),
    M is N - 1,
    rnd_select(XR, M, LT).

lotto(N, M, L) :-
    range(1, M, S),
    rnd_select(S, N, L).

rnd_permu(X, L) :-
    length(X, NX),
    rnd_select(X, NX, L).

combination(0, _, []) :- !.
combination(K, [H | T], Y) :-
    K1 is K - 1, combination(K1, T, YT), Y = [H | YT];
    combination(K, T, Y).

group3([], [], [], []) :- !.
group3([H | T], [H | G1], G2, G3) :- group3(T, G1, G2, G3), length(G1, N), N < 2.
group3([H | T], G1, [H | G2], G3) :- group3(T, G1, G2, G3), length(G2, N), N < 3.
group3([H | T], G1, G2, [H | G3]) :- group3(T, G1, G2, G3), length(G3, N), N < 4.

one_group(X, 0, [], X) :- !.
one_group([H | T], N, [H | Y], Z) :- M is N - 1, one_group(T, M, Y, Z).
one_group([H | T], N, Y, [H | Z]) :- one_group(T, N, Y, Z).

group(_, [], []).
group(X, [N | T], [GH | GT]) :-
    one_group(X, N, GH, NX),
    group(NX, T, GT).

get_min(_, [X], X, []).
get_min(F, [H | T], Y, Z) :-
    get_min(F, T, YT, ZT),
    call(F, H, NH),
    call(F, YT, NYT),
    (NH < NYT -> Y = H, Z = T;
     Y = YT, Z = [H | ZT]).

my_sort(_, [], []).
my_sort(F, X, [H | ST]) :-
    get_min(F, X, H, T),
    my_sort(F, T, ST).

lsort(X, Y) :- my_sort(length, X, Y).

length_frequency([], _, 0).
length_frequency([H | T], L, N) :-
    length_frequency(T, L, NT),
    length(H, HL),
    (HL = L -> N is NT + 1; N is NT).

list_length_frequency(X, E, Y) :- length(E, L), length_frequency(X, L, Y).

lfsort(X, Y) :- my_sort(list_length_frequency(X), X, Y).
