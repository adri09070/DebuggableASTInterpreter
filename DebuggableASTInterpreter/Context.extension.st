Extension { #name : #Context }

{ #category : #'*DebuggableASTInterpreter' }
Context >> asDASTContextInterpretedBy: aDASTInterpreter [

	| dastCtx bindings aimedNode currentNode dastSender closureToDASTBlock tempNames |
	closureToDASTBlock := Dictionary new.
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
				           receiver: (closureOrNil
						            ifNil: [
							            self
								            dastValueFor: receiver
								            interpretedBy: aDASTInterpreter
								            withClosureToBlockDictionary: closureToDASTBlock ]
						            ifNotNil: [
							            | dastBlock |
							            dastBlock := self
								                         dastValueFor: closureOrNil
								                         interpretedBy: aDASTInterpreter
								                         withClosureToBlockDictionary:
								                         closureToDASTBlock.
							            (dastBlock outerContext isNil or: [
								             dastBlock outerContext isDead not ])
								            ifTrue: [ "DASTBlock new
							            nodeAST: closureOrNil compiledBlock ast;
							            outerContext: (dastSender isRoot
									             ifFalse: [ dastSender ]
									             ifTrue: ["
									            self flag:
										            'Maybe it is weird that the outer context is a context but I haven''t found a better solution yet.'.
									            dastBlock
										            outerContext: self outerContext;
										            "]);
							            yourself
								            dastBlock
									            outerContext:
										            (self outerContext asDASTContextInterpretedBy:
												             aDASTInterpreter);
									            yourself ]"
											            yourself ]
								            ifFalse: [ dastBlock ] ])
				           messageNode: (dastSender isRoot
						            ifTrue: [
							            RBMessageNode
								            receiver: (RBLiteralValueNode value: nil)
								            selector: #value ]
						            ifFalse: [ sender sourceNodeExecuted ])
				           evaluator: aDASTInterpreter evaluator ].
	DASTContext bcToDASTContextMap at: self put: dastCtx.
	bindings := Dictionary new.
	"need to find right set of temp names"
	tempNames := (self isBlockContext and: [
		              (DASTContext bcToDASTContextMap keys
			               detect: [ :each | each == self outerContext ]
			               ifNone: [ nil ]) isNotNil ])
		             ifTrue: [
		             self tempNames difference: self outerContext tempNames ]
		             ifFalse: [ self tempNames ].
	tempNames do: [ :tempName |
		| contextTemp dastTemp |
		contextTemp := self tempNamed: tempName.
		dastTemp := self
			            dastValueFor: contextTemp
			            interpretedBy: aDASTInterpreter
			            withClosureToBlockDictionary: closureToDASTBlock.
		bindings at: tempName put: dastTemp ].
	dastCtx isDead: self isDead.
	dastCtx temps: bindings associations.

	self pc
		ifNil: [
			aimedNode := dastCtx nodes first.
			dastCtx isDead: true ]
		ifNotNil: [ aimedNode := self compiledCode sourceNodeForPC: self pc ].
	[ aimedNode == dastCtx nodes top ] whileFalse: [
		dastCtx executedNodes push: (currentNode := dastCtx nodes pop) ].
	dastCtx currentNode: currentNode.
	(Interval from: self numTemps + 1 to: self stackPtr) do: [ :each |
		dastCtx stack push: (self
				 dastValueFor: (self at: each)
				 interpretedBy: aDASTInterpreter
				 withClosureToBlockDictionary: closureToDASTBlock) ].
	closureToDASTBlock do: [ :each |
		each outerContext: (DASTContext bcToDASTContextMap
				 at: self outerContext
				 ifAbsent: [ self outerContext ]) ].
	^ dastCtx
]

{ #category : #'*DebuggableASTInterpreter' }
Context >> nodeForCurrentPC [
	
	 ^ self method ast sourceNodeForPC: pc

]
