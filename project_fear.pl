/* Fear, by Keric Ajdin and Wizany Dominik. */

:- dynamic i_am_at/1, at/2, holding/1.
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)).

holding([]).

i_am_at(intersection_outside).

path(intersection_outside, s, escape).
path(intersection_outside, n, mansion_entrance).
path(intersection_outside, e, key_street).
path(intersection_outside, w, life_street). 

path(life_street, e, intersection_outside). 
path(key_street, w, intersection_outside). 
path(mansion_entrance, s, intersection_outside). 

path(mansion_entrance, n, mansion_exit). 

path(mansion_exit, s, mansion_entrance). 
path(mansion_exit, w, darkhallway). 
path(mansion_exit, e, dollroom). 
path(mansion_exit, n, stairsroom). 

at(thing, someplace).
at(entrancekey, key_street).
at(ball, intersection_outside).

/* These rules describe how to pick up an object. */

take(X) :-
        holding(Y), member(X, Y),
        write('You''re already holding it!'),
        !, nl.

take(X) :-
        i_am_at(Place),
        at(X, Place),
        retract(at(X, Place)),
        holding(List),
        append(List, [X], NewList),
        retractall(holding()),
        assert(holding(NewList)),
        write('OK.'),
        !, nl.

take(_) :-
        write('I don''t see it here.'),
        nl.


/* These rules describe how to put down an object. */

drop(X) :-
        holding(X),
        i_am_at(Place),
        retract(holding(X)),
        assert(at(X, Place)),
        write('OK.'),
        !, nl.

drop(_) :-
        write('You aren''t holding it!'),
        nl.


/* These rules define the direction letters as calls to go/1. */

n :- go(n).

s :- go(s).

e :- go(e).

w :- go(w).


/* This rule tells how to move in a given direction. */

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, There),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        !, look.

go(_) :-
        write('You can''t go that way.').


/* This rule tells how to look about you. */

look :-
        i_am_at(Place),
        describe(Place),
        nl,
        notice_objects_at(Place),
        nl.


/* These rules set up a loop to mention all the objects
   in your vicinity. */

notice_objects_at(Place) :-
        at(X, Place),
        write('There is a '), write(X), write(' here.'), nl,
        fail.

notice_objects_at(_).


/* This rule tells how to die. */

die :-
        finish.


/* Under UNIX, the "halt." command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final "halt." */

finish :-
        nl,
        write('The game is over. Please enter the "halt." command.'),
        nl.


/* This rule just writes out game instructions. */

instructions :-
        nl,
        write('Enter commands using standard Prolog syntax.'), nl,
        write('Available commands are:'), nl,
        write('start.             -- to start the game.'), nl,
        write('n.  s.  e.  w.     -- to go in that direction.'), nl,
        write('take(Object).      -- to pick up an object.'), nl,
        write('drop(Object).      -- to put down an object.'), nl,
        write('look.              -- to look around you again.'), nl,
        write('instructions.      -- to see this message again.'), nl,
        write('halt.              -- to end the game and quit.'), nl,
        nl.


/* This rule prints out instructions and tells where you are. */

start :-
        instructions,
        look.


/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description. */

describe(intersection_outside) :- write('You are standing infront of a mansion. It looks abandoned and the atmosphere is terrifying.'), nl,
                                  write('To your left and to your right you see nothing but emptiness. You can still go there and check the place out.'), nl,
                                  write('Behind you are stairs. You can''t identify where they lead to'), nl.
describe(escape) :- write('You hoped that the stairs would lead back to normal life. A few minutes pass before you see a brighter light.'), nl,
                    write('You start running and suddenly you wake up, all sweaty and shocked. You prepare for todays day in the Higher Technical Colleague in Leonding.'), nl,
                    write('But what you don''t know is, that the nightmare is just beginning'), nl.
describe(mansion_entrance) :- write('The door of the mansion is preventing you to enter it.'), nl,
                            write('You have to go look for a key.'), nl,
                            write('Going South leads back to the intersection.'), nl.
describe(key_street) :- write('As brave as you are you went to the right and saw nothing else than emptiness.'), nl,
                        write('You are looking around and spotted a key infront of you.'), nl,
                        write('Maybe this key has something to do with the mansion'), nl.
                        write('Going West leads back to the intersection'), nl.
describe(life_street) :- write('As brave as you are you went to the left and saw nothing else than emptiness'), nl,
                         write('You are thinking about how you got there.'), nl,
                         write('Going West leads back to the intersection'), nl.
describe(mansion_exit) :- write('The mansion really is big. You noticed that even though the mansion is abandoned that chandeliers and torches are still burning.'), nl,
                          write('Going North leads to another big room. In thee angle of view you can still see stairs that go up and down.'), nl,
                          write('Going East leads to a suspicious looking room.'), nl,
                          write('Going West leads to a dark and long hallway.'), nl,
                          write('Going South leads to the exit door.'), nl,
describe(darkhallway) :- write('You see 4 paintings and under every of them you can see a sign with the name of the artist.'), nl,
                         write('Every step you make in the hallway makes the floor squeaking. The floor is for sure not built properly.'), nl,
                         write('Going West leads to a small room with a closet.'), nl,
                         write('Going East leads back to the exit of the mansion.'), nl,
describe(dollroom) :- write('Going into the room you can see that the torches are purple now. It looks like a ritual room and on the floor is a pentagram.'), nl,
                      write('Meters away you see a doll.'), nl,
                      write('Going East leads to a closer look at the doll.'), nl,
                      write('Going West leads back to the exit of the mansion.'), nl,
describe(stairsroom) :- write('Looking around you can see two stairs.'), nl,
                        write('The stairs to the East go up.'), nl,
                        write('The stairs to the West go down.'), nl,
                        write('Going South leads back to the exit of the mansion'), nl.
                          

inventory :- 
        holding(Y), 
        not(proper_length([Y], 0)), 
        write(Y).