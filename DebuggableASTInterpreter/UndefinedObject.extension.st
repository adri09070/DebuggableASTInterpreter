Extension { #name : #UndefinedObject }

{ #category : #'*DebuggableASTInterpreter' }
UndefinedObject >> asDASTContextInterpretedBy: aDastInterpreter [
	^ DASTContextRootSmalltalk new
]

{ #category : #'*DebuggableASTInterpreter' }
UndefinedObject >> nodeForCurrentPC [
	 ^ nil
]
