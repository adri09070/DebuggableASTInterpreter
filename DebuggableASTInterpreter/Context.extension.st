Extension { #name : #Context }

{ #category : #'*DebuggableASTInterpreter' }
Context >> asDASTContextInterpretedBy: aDASTInterpreter [

	| dastCtx bindings aimedNode currentNode dastSender |

	bindings := Dictionary new.
	self tempNames do: [ :tempName |
		bindings at: tempName put: (self tempNamed: tempName) ].
	dastCtx := self compiledCode isDoIt
		           ifTrue: [
			           DASTContext
				           newNoMethodContextWithProgram: self compiledCode ast
				           temps: {  }
				           evaluator: aDASTInterpreter evaluator ]
		           ifFalse: [
			           DASTContext
				           newWithSender:
				           (dastSender := sender asDASTContextInterpretedBy:
					                          aDASTInterpreter)
				           receiver:
					           (closureOrNil ifNil: [ receiver ] ifNotNil: [
						            DASTBlock new
							            nodeAST: closureOrNil compiledBlock ast;
							            outerContext: dastSender;
							            yourself ])
				           messageNode: (dastSender isRoot
						            ifTrue: [
							            RBMessageNode
								            receiver: (RBLiteralValueNode value: nil)
								            selector: #value ]
						            ifFalse: [ sender sourceNodeExecuted ])
				           evaluator: aDASTInterpreter evaluator ].
	dastCtx temps: bindings associations.

	aimedNode := self compiledCode sourceNodeForPC: self pc.
	[ aimedNode == dastCtx nodes top ] whileFalse: [
		dastCtx executedNodes push: (currentNode := dastCtx nodes pop) ].
	dastCtx currentNode: currentNode.
	(Interval from: self numTemps + 1 to: self stackPtr) do: [ :each |
		dastCtx stack push: (self at: each) ].
	^ dastCtx
]

{ #category : #'*DebuggableASTInterpreter' }
Context >> nodeForCurrentPC [
	
	 ^ self method ast sourceNodeForPC: pc

]
