Extension { #name : 'RBProgramNode' }

{ #category : '*DebuggableASTInterpreter' }
RBProgramNode >> asBlockEvaluated [
	| sequenceNode blockNode messageNode |

	sequenceNode := self asSequenceNode transformLastToReturn.
	blockNode := RBBlockNode body: sequenceNode.
	messageNode := RBMessageNode receiver: blockNode selector: #value.
	
	^ messageNode
]

{ #category : '*DebuggableASTInterpreter' }
RBProgramNode >> isDASTClosure [ 
	^false
]
