Extension { #name : #Context }

{ #category : #'*DebuggableASTInterpreter' }
Context >> asDASTContextInterpretedBy: aDASTInterpreter [

	| dastCtx bindings |
	bindings := Dictionary new.
	self tempNames do: [ :tempName | 
		bindings at: tempName put: (self tempNamed: tempName) ].
	dastCtx := [ 
	           (DASTContext
		            newWithSender:
			            (sender asDASTContextInterpretedBy: aDASTInterpreter)
		            receiver:
			            (sender ifNil: [ closureOrNil ] ifNotNil: [ receiver ])
		            messageNode: (sender
				             ifNil: [ 
					             closureOrNil ifNotNil: [ 
							             RBMessageNode
								             receiver: RBValueNode new
								             selector: #value ] ]
				             ifNotNil: [ sender sourceNodeExecuted ])
		            evaluator: aDASTInterpreter evaluator)
		           temps: bindings associations;
		           yourself ]
		           on: Exception
		           do: [ :exc | ^ DASTContextRootSmalltalk new ].
	^ dastCtx
]

{ #category : #'*DebuggableASTInterpreter' }
Context >> nodeForCurrentPC [
	
	 ^ self method ast sourceNodeForPC: pc

]
