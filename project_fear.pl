/* Fear, by Keric Ajdin and Wizany Dominik. */

:- dynamic i_am_at/1, at/2, holding/1, fearcount/1.
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

path(mansion_exit, s, mansion_entrance) :- checkinventory(key). 
path(mansion_exit, w, darkhallway) :- checkinventory(torch).
path(mansion_exit, e, dollroom). 
path(mansion_exit, n, stairsroom). 

path(mansion_entrance, n, mansion_exit) :- checkinventory(entrancekey).

path(darkhallway, e, mansion_exit). 
path(darkhallway, w, closetroom).

path(dollroom, w, mansion_exit). 

path(stairsroom, s, mansion_exit). 

path(stairsroom, e, upstairsroom). 
path(stairsroom, w, downstairsroom).

path(upstairsroom, w, stairsroom).
path(upstairsroom, n, roomwithchest).

path(roomwithchest, w, floor1reducer).
path(roomwithchest, s, upstairsroom).

path(floor1reducer, e, roomwithchest).

path(downstairsroom, n, keyroom) :- checkinventory(demkey).
path(downstairsroom, e, stairsroom).

path(keyroom, s, downstairsroom).

path(dollroom, e, pentagramarea).
path(dollroom, w, mansion_exit).

path(pentagramarea, w, dollroom).

path(darkhallway, w, closetroom).
path(darkhallway, jump, tchamber) :- write('Ah shiet. As you jumped the floor broke.'), nl,
                                     write('You are in a dark room, but the torch is brightening up the room.'), nl,
                                     write('You do not know where you are.'), nl,
                                     write('There is no door and you can''t get out of this room.'), nl,
                                     write('You question yourself why you jumped. You knew that something bad will happen'), nl,
                                     write('You lost sense of time.'), nl,
                                     write('You died by dehydration.'), die.
path(darkhallway, e,mansion_exit).

path(closetroom, e, darkhallway).
path(closetroom, n, traproom) :- write('As you enter the room you trip on a thread.'), nl,
                                 write('At first nothing happened but seconds later you hear something rolling.'), nl,
                                 write('Before you even could run away, a trapdoor above you opened and a big rock fell down'), nl,
                                 write('You got crushed.'), die.


at(entrancekey, key_street).
at(ball, intersection_outside).
at(torch, mansion_exit).
at(doll, pentagramarea).
at(key, keyroom).
at(keyroom, exitkey).

look_at(firstpainting, darkhallway).
look_at(secondpainting, darkhallway).
look_at(thirdpainting, darkhallway).
look_at(fourthpainting, darkhallway).

inter_at(firstbutton, roomwithchest).
inter_at(secondbutton, roomwithchest).
inter_at(thirdbutton, roomwithchest).
inter_at(fourthbutton, roomwithchest).
inter_at(altar, stairsroom) :- checkinventory(skull).
inter_at(closet, closetroom).
inter_at(bed, floor1reducer).

/*Checks if you are holding an item*/

member(X, [X|_]).
member(X, [_|T]) :- member(X,T).

checkinventory(X) :- holding(Y), member(X, Y), member(X, [_|Y]).
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
        retractall(holding(_)),
        assert(holding(NewList)),
        describe(X),
        !, nl.

take(_) :-
        write('I don''t see it here.'),
        nl.

takeskull :-
        holding(List),
        append(List, [skull], NewList),
        retractall(holding(_)),
        assert(holding(NewList)),
        describe(skull),
        !, nl.

takedemkey :-
        holding(List),
        append(List, [demkey], NewList),
        retractall(holding(_)),
        assert(holding(NewList)),
        describe(demkey),
        !, nl.

/* These rules describe how to investigate an object. */

investigate(X) :-
               i_am_at(Place),
               inter_at(X, Place),
               describe(X),
               !, nl.

investigate(_) :-
               write('I don''t see it here.'),
               nl.


/* These rules describe how to interact with an object. */

interact(X) :-
               i_am_at(Place),
               inter_at(X, Place),
               describe(X),
               !, nl.

interact(_) :-
               write('I don''t see it here.'),
               nl.

/* These rules describe how to put down an object. */

drop(X) :-
        holding(List),
        delete(List, X, L),
        i_am_at(Place),
        retractall(holding(List)),
        assert(holding(L)),
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

jump :- go(jump).


/* This rule tells how to move in a given direction. */

go(_) :-
        fearcount(X),
        X > 20,
        write('You have reached the point where you can not keep your eyes open from fear.'), nl,
        write('You pass out...'),
        die.

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, There),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        incrfear,
        !, look.

go(n) :-
        i_am_at(mansion_entrance),
        write('The door is locked.').

go(w) :-
        i_am_at(mansion_exit),
        write('The hallway is too dark. You need a light source.').

go(s) :-
        i_am_at(mansion_exit),
        write('You try to open the door with the key you picked up in the beginning.'), nl,
        write('It won''t open. It''s locked!'), nl,
        write('Looks like this will be a long night :)').

go(n) :-
        i_am_at(downstairsroom),
        write('The door is locked. But considering how it looks, it might be better that way.').

go(_) :-
        write('You can''t go that way.').


/* This rule tells how to look about you. */

look :-
        i_am_at(Place),
        describe(Place),
        nl,
        nl,
        notice_objects_at(Place),
        notice_things_to_look_at(Place),
        notice_things_to_interact_with(Place),
        nl.

/* These rules set up a loop to mention all the objects
   in your vicinity. */

notice_objects_at(Place) :-
        at(X, Place),
        write('There is a '), write(X), write(' here.'), nl,
        fail.

notice_objects_at(_).

notice_things_to_look_at(Place) :-
        look_at(X, Place),
        write('You can investigate the '), write(X), write('.'), nl,
        fail.

notice_things_to_look_at(_).

notice_things_to_interact_with(Place) :-
        inter_at(X, Place),
        write('You can interact with the '), write(X), write('.'), nl,
        fail.
notice_things_to_interact_with(_).

/* This rule tells how to die. */

die :-
        finish.


/* These rules describe the fear mechanik */

init :- 
        retractall(fearcount(_)),
        assertz(fearcount(0)).

incrfear :-
        checkdoll,
        fearcount(V0),
        retractall(fearcount(_)),
        succ(V0,V), 
        assertz(fearcount(V)).
incrfear :-
        fearcount(V0),
        retractall(fearcount(_)),
        succ(V0,V), 
        assertz(fearcount(V)).

sleep :-
        retractall(fearcount(_)),
        assertz(fearcount(0)).

checkfear :-
        fearcount(X),
        write(X).

checkdoll :-
        checkinventory(doll),
        fearcount(V0),
        retractall(fearcount(_)),
        succ(V0,V), 
        assertz(fearcount(V)).

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
        write('instructions.         -- to see this message again.'), nl,
        write('start.                -- to start the game.'), nl,
        write('n.  s.  e.  w.  jump. -- to go in that direction.'), nl,
        write('take(Object).         -- to pick up an object.'), nl,
        write('drop(Object).         -- to put down an object.'), nl,
        write('investigate(Object).  -- to investigate an object.'), nl,
        write('interact(Object)      -- to interact with an object.'), nl,
        write('look.                 -- to look around you again.'), nl,
        write('halt.                 -- to end the game and quit.'), nl,
        write('checkfear.            -- to check your fear meter.'), nl,
        write('The fear meter portrais your anxiety and increases with chertain actions.'), nl,
        write('Try to keep it below 20 or you might get a little bit too scared...'), nl,
        nl.


/* This rule prints out instructions and tells where you are. */

start :-
        instructions,
        init,
        look.


/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description. */

/* rooms */

describe(intersection_outside) :- write('You are standing infront of a mansion. It looks abandoned and the atmosphere is terrifying.'), nl,
                                  write('To your left and to your right you see nothing but emptiness. You can still go there and check the place out.'), nl,
                                  write('Behind you are stairs. You can''t identify where they lead to.').
describe(escape) :- write('You hoped that the stairs would lead back to normal life. A few minutes pass before you see a brighter light.'), nl,
                    write('You start running and suddenly you wake up, all sweaty and shocked. You prepare for todays day in the Higher Technical Colleague in Leonding.'), nl,
                    write('But what you don''t know is, that the nightmare is just beginning...'), nl, finish.
describe(mansion_entrance) :- write('You are standing infront of the door of the mansion.'), nl,
                            write('Going South leads back to the intersection.').
describe(key_street) :- write('As brave as you are you went to the right and saw nothing else than emptiness.'), nl,
                        write('You are looking around and spotted a key infront of you.'), nl,
                        write('Going West leads back to the intersection.').
describe(life_street) :- write('As brave as you are you went to the left and saw nothing else than emptiness.'), nl,
                         write('You are thinking about how you got there.'), nl,
                         write('Going East leads back to the intersection.').
describe(mansion_exit) :- write('The mansion really is big. You noticed that even though the mansion is abandoned that chandeliers and torches are still burning.'), nl,
                          write('Going North leads to another big room. In thee angle of view you spot stairs that go up and down.'), nl,
                          write('Going East leads to a suspicious looking room.'), nl,
                          write('Going West leads to a dark and long hallway.'), nl,
                          write('Going South leads to the exit door.').
describe(darkhallway) :- write('You see 4 paintings and under every of them you can see a sign with the name of the artist.'), nl,
                         write('Every step you make in the hallway makes the floor squeaking. The floor is for sure not built properly.'), nl,
                         write('Going West leads to a small room with a closet.'), nl,
                         write('Going East leads back to the exit of the mansion.'), nl,
                         write('There is something on the ceiling. You could try to jump and get it.').
describe(dollroom) :- write('Going into the room you can see that the torches are purple now. It looks like a ritual room and on the floor is a pentagram.'), nl,
                      write('Meters away you see a doll.'), nl,
                      write('Going East leads to a closer look at the pentagram.'), nl,
                      write('Going West leads back to the exit of the mansion.').
describe(stairsroom) :- write('Looking around you can see two stairs.'), nl,
                        write('In front of you is an altar. It looks like it is missing something.'), nl,
                        write('The stairs to the East go up.'), nl,
                        write('The stairs to the West go down.'), nl,
                        write('Going South leads back to the exit of the mansion.').
describe(upstairsroom) :- write('You are on the first floor. You noticed that this area has a lot of dust and cobwebs.'), nl,
                          write('Going West leads to the room with the stairs.'), nl,
                          write('Going North leads to a dark room.').
describe(downstairsroom) :- write('You find yourself in the basement of the Mansion.'), nl,
                            write('It is cold and dark. You get goosebumps.'), nl,
                            write('There is a scary looking door to the North with a keyhole shaped like a skull.'), nl,
                            write('Going East leads back to the stairs room.').    
describe(roomwithchest) :- write('You are now within a small and dark room, containing a chest.'), nl,
                           write('As you look closer you can see four buttons on the wall.'), nl,
                           write('Next to the buttons there is a note reading:'), nl,
                           write('"Among the four there is one impostor. It shall guide you to your destination."'), nl,
                           write('Going West leads to a room that does not fit the spooky atmosphere at all.'), nl,
                           write('Going South leads back to the stairs.').
describe(closetroom) :- write('There is a closet in the middle of the Room. Maybe there is something interesting inside.'), nl,
                        write('To the north there is a suspicious looking room. Maybe something hides in there.'), nl,
                        write('Going East leads to the dark hallway.').
describe(pentagramarea) :- write('You are now standing in front of the Pentagram.'), nl,
                           write('Going West leads back to the entrance of the room.').
describe(keyroom) :- write('You are in a small room with a hook on the wall.'), nl,
                     write('Going South leads back to the downstairs room.').
describe(floor1reducer) :- write('You are in a very well lit and soothing room.'), nl,
                           write('The atmosphere is very different to the rest of the mansion.'), nl,
                           write('There is a comfy looking bed which looks like it could be rested upon.'), nl,
                           write('Going East leads back to the chest room.').
                

/* items */

describe(ball) :- write('Obtained a regular ball.').
describe(entrancekey) :- write('Obtained a normal looking key. Maybe it has something to do with the mansion.').
describe(doll) :- write('Obtained a scary looking doll. It reminds you of a voodoo doll.').
describe(torch) :- write('Obtained a torch. It emmits a warm light.').
describe(chestkey) :- write('Obtained a key that looks like it could fit in a chest.').
describe(skull) :- write('Obtained a skull. It looks like it can be used in some kind of ritual.').
describe(demkey) :- write('Obtained demonic looking key.').
describe(key) :- write('Obtained yet another key. It looks somewhat similar to the first one.').

/* interactable objects */

describe(firstpainting) :- write('As you look at the sign, you read that the painting was drawn by "Vincent Van Gogh".'), nl,
                           write('You remember from a movie that the painting is called "12 Sunflowers".'), nl.
describe(secondpainting) :- write('As you look at the sign, you read that the painting was drawn by "Leonardo Da Vinci".'), nl,
                            write('It''s one of his most famous paintings, the Mona Lisa!'), nl.
describe(thirdpainting) :- write('As you look at the sign, you read that the painting was drawn by "Pablo Picasso".'), nl,
                           write('You have seen that painting before on a tv show. It''s called "Guernica".'), nl.
describe(fourthpainting) :- write('As you look at the sign, you read that the painting was drawn by "Conan Van Zix".'), nl,
                            write('It''s a painting of a man that turns into a demon.'), nl,
                            write('You have never heard of him and the painting also looks terrifying.'), nl.
describe(firstbutton) :- write("You press the button but it does not seem to do anything."), nl,
                         write("Suddenly you notice that the Door is closed and you also smell a strong scent."), nl,
                         write("The smell is overwhelming and you start to lose consciousness."), nl, die.
describe(secondbutton) :- write("You press the button but it does not seem to do anything."), nl,
                          write("Suddenly you notice that the Door is closed and you also smell a strong scent."), nl,
                          write("The smell is overwhelming and you start to lose consciousness."), nl, die.
describe(thirdbutton) :- write("You press the button but it does not seem to do anything."), nl,
                         write("Suddenly you notice that the Door is closed and you also smell a strong scent."), nl,
                         write("The smell is overwhelming and you start to lose consciousness."), nl, die.
describe(fourthbutton) :- write('You press the fourth button and immediatly hear a sound from the other side of the room.'), nl,
                          write('It turns out that the chest is now open and inside it there is a skull.'), nl,
                          write('You decide to pick it up.'), nl, takeskull.
describe(altar) :- write('You place the skull onto the altar.') , nl,
                   write('The candles suddenly get lit lighting up the room.'), nl,
                   write('A demonic looking key suddenly appeared and you decide to take it.'), nl, takedemkey.
describe(closet) :- write('You open the closet, which turns out to be empty.'), nl,
                    write('But suddenly you hear a loud scream coming deep from within the mansion...'), nl,
                    write('You slowly close the closet...'), incrfear, incrfear, incrfear, incrfear, incrfear. 
describe(bed) :- write('You lay down and close your eyes.'), nl,
                 write('strangely the atmosphere of the room makes it possible to relax quite a bit.'), nl,
                 write('You feel a lot less stressed out.'), sleep.
inventory :- 
        holding(Y), 
        not(proper_length([Y], 0)), 
        write(Y).