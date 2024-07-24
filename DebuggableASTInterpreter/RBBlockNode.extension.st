Extension { #name : 'RBBlockNode' }

{ #category : '*DebuggableASTInterpreter' }
RBBlockNode >> sourceCode [
	^ [ super sourceCode ] on: Exception do: [ '' ]
]
