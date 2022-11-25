Extension { #name : #Context }

{ #category : #'*DebuggableASTInterpreter' }
Context >> asDASTContextInterpretedBy: aDASTInterpreter [

	| dastCtx |
	dastCtx := DASTContext
		           newWithSender:
		           (sender asDASTContextInterpretedBy: aDASTInterpreter)
		           receiver: (sender ifNil: [closureOrNil] ifNotNil:[receiver])
		           messageNode: (sender
				            ifNil: [ 
					            closureOrNil ifNotNil: [ 
						            RBMessageNode
							            receiver: RBValueNode new
							            selector: #value ] ]
				            ifNotNil: [ 
				            sender sourceNodeExecuted ])
		           evaluator: aDASTInterpreter evaluator.
	^ dastCtx
]

{ #category : #'*DebuggableASTInterpreter' }
Context >> nodeForCurrentPC [
	
	 ^ self method ast sourceNodeForPC: pc

]
