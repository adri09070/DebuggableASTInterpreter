Extension { #name : #StDebuggerObjectForTests }

{ #category : #'*DebuggableASTInterpreter' }
StDebuggerObjectForTests >> methodWithTempsAssignments [

	| a b |
	a := 40.    
	b := 2.     
	^ a + b  
]
