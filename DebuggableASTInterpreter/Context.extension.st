Extension { #name : #Context }

{ #category : #'*DebuggableASTInterpreter' }
Context >> asDASTContextInterpretedBy: aDASTInterpreter [

	| dastCtx bindings aimedNode currentNode |
	"set current node and executed node stack and next nodes stack"
	bindings := Dictionary new.
	self tempNames do: [ :tempName |
		bindings at: tempName put: (self tempNamed: tempName) ].
	dastCtx := [
	           (DASTContext
		            newWithSender:
			            (sender asDASTContextInterpretedBy: aDASTInterpreter)
		            receiver:
			            (sender
				             ifNil: [ closureOrNil "compiledBlock" ]
				             ifNotNil: [ receiver ])
		            messageNode: (sender
				             ifNil: [
					             closureOrNil ifNotNil: [
							             RBMessageNode
								             receiver: RBLiteralValueNode new
								             selector: #value ] ]
				             ifNotNil: [ sender sourceNodeExecuted ])
		            evaluator: aDASTInterpreter evaluator)
		           temps: bindings associations;
		           yourself ]
		           on: Exception
		           do: [ :exc | "UIManager inform: exc printString."
			           ^ DASTContextRootSmalltalk new
				             currentNode:
					             (RBMessageNode
						              receiver: RBLiteralValueNode new
						              selector: #value);
				             yourself ].

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
