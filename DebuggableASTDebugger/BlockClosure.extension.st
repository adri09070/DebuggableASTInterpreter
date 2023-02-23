Extension { #name : #BlockClosure }

{ #category : #'*DebuggableASTDebugger' }
BlockClosure >> bcToDASTValue [

	^ DASTBlock new
		  initializeWith: self compiledBlock ast;
		  pharoOuterContext: self outerContext;
		  yourself
]
