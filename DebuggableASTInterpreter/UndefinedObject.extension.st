Extension { #name : #UndefinedObject }

{ #category : #'*DebuggableASTInterpreter' }
UndefinedObject >> asDASTContextInterpretedBy: aDastInterpreter [

	^ DASTContextRootSmalltalk new
		  currentNode: (RBMessageNode
				   receiver: (RBLiteralValueNode value: nil)
				   selector: #value);
		  yourself
]

{ #category : #'*DebuggableASTInterpreter' }
UndefinedObject >> nodeForCurrentPC [
	 ^ nil
]
