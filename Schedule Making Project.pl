cls :- write('\33\[2J').

% Knowledge Base
%_______________

slots([slot(sunday,1),slot(sunday,2),slot(sunday,3),slot(monday,1),slot(monday,2),
slot(monday,3),slot(tuesday,1),slot(tuesday,2),slot(tuesday,3),slot(wednesday,1),
slot(wednesday,2),slot(wednesday,3)]).

courses([(csen403,2),(csen905,2),(csen709,1),(csen601,2),(csen301,3),(csen701,2)
,(csen503,3),(csen501,2)]).


% Predicates
%___________

no_occurences([]).
no_occurences([H|T]):-
					\+ member(H,T),
					no_occurences(T).


suitablePairs([],[]).
suitablePairs([H|T],ListOfPairs):-
								suitablePairs(T,T1),
								append([(H,_)],T1,ListOfPairs).


putSlots(L):-
			
			slots(Values),
			suitablePairs(Values,L),
			no_occurences(L).
			
			

courseNotDone([],_).
courseNotDone(L, C):-
					\+ member(C, L).


convertListOfCoursesToListPairs([],[]).
convertListOfCoursesToListPairs([H|T], Results):-
												R1 = (H,_),
												convertListOfCoursesToListPairs(T, R2),
												append([R1],R2,Results).


pickAnotDoneCourse([H|_], DoneCourses, H):-	
										convertListOfCoursesToListPairs(DoneCourses, DCPairs),
										\+ member(H,DCPairs).										
pickAnotDoneCourse([_|T], DoneCourses, R):-		
										pickAnotDoneCourse(T, DoneCourses, R).										
pickAnotDoneCourse([H|T], DoneCourses, R):-	
										convertListOfCoursesToListPairs(DoneCourses, DCPairs),
										member(H,DCPairs),
										pickAnotDoneCourse(T, DoneCourses, R).


removeFromNotDone(_,[],[]).
removeFromNotDone(C,L,L2):-
						member(C, L),
						delete(L,C,L2).

suitableCourse(_, NeededSlots, NeededSlots).
suitableCourse([(_,SlotValue)|T], NeededSlots, Counter):-
														var(SlotValue),
														Counter < NeededSlots,
														NewC is Counter + 1,
														suitableCourse(T, NeededSlots, NewC).
suitableCourse([(_,SlotValue)|T], NeededSlots, Counter):-
														\+ var(SlotValue),
														suitableCourse(T, NeededSlots, Counter).


scheduleCourse([(_,X)|_], Name, 1):-
									var(X),
									X = Name.
scheduleCourse([(_,X),(_,Y)|T], Name, N):-
									N = 2,
									var(X),
									var(Y),
									append([(_, X)],[(_,Y)],L1),
									append(L1,T, L2),
									suitableCourse(L2, N, 0),
									X = Name,
									Y = Name.
scheduleCourse([(_,X),(_,Y),(_,Z)|T], Name, N):-
									N = 3,
									var(X),
									var(Y),
									var(Z),
									append([(_, X)],[(_,Y)],L1),
									append(L1,[(_,Z)], L2),
									append(L2,T, L3),
									suitableCourse(L3, N, 0),
									X = Name,
									Y = Name,
									Z = Name.
scheduleCourse([(_,W),(_,X),(_,Y),(_,Z)|T], Name, N):-
									N = 4,
									var(W),
									var(X),
									var(Y),
									var(Z),
									append([(_, W)],[(_,X)],L1),
									append([(_, Y)],[(_,Z)],L2),
									append(L1, L2, L3),
									append(L3, T, L4),
									suitableCourse(L4, N, 0),
									W = Name,
									X = Name,
									Y = Name,
									Z = Name.									
scheduleCourse([_|T], Name, N):-
							scheduleCourse(T, Name, N).



schedule(_, _, _, 0, 0).
					
schedule(L, DoneCourses, [(CourseName, CourseSlots)|_], AvailableSlots, 0):-
					AvailableSlots \= 0,
					AvailableSlots < CourseSlots,
					scheduleCourse(L, CourseName, AvailableSlots),
					%length(DoneCourses, DS),
					%N = DS,
					NewAvailableSlots is AvailableSlots -1,
					schedule(_, DoneCourses, _, NewAvailableSlots, _).					
					
schedule(L, DoneCourses, [(CourseName, CourseSlots)|T], AvailableSlots, DoneSubjN):-
					AvailableSlots > 0,
					AvailableSlots >= CourseSlots,				
					append([(CourseName, CourseSlots)], T, UndoneCourses),
					length(UndoneCourses, UndoneCoursesLength),
					UndoneCoursesLength > 0,
					scheduleCourse(L, CourseName, CourseSlots),
					removeFromNotDone((CourseName, CourseSlots), UndoneCourses, NewUndoneCourses),
					append([(CourseName, CourseSlots)], DoneCourses, NewDoneCourses),
					NewAvailableSlots is AvailableSlots - CourseSlots,
					%length(NewDoneCourses, DoneSubjNum),
					%DS = DoneSubjNum,
					schedule(L, NewDoneCourses, NewUndoneCourses, NewAvailableSlots, DS),
					DoneSubjN is DS + 1 .

solve(L,DoneSubjN):-
					putSlots(L),
					length(L,N),
					courses(NotDone),
					sort(2,@=<,NotDone,SortedCourses),
					schedule(L,[],SortedCourses,N,DoneSubjN).









			