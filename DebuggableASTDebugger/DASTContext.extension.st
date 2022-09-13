Extension { #name : #DASTContext }

{ #category : #'*DebuggableASTDebugger' }
DASTContext >> currentNode [ 	
	^self nodes top
]

{ #category : #'*DebuggableASTDebugger' }
DASTContext >> messageNode [
	^messageNode
]

{ #category : #'*DebuggableASTDebugger' }
DASTContext >> method [
	^self methodOrBlock nodeAST compiledMethod
]

{ #category : #'*DebuggableASTDebugger' }
DASTContext >> methodContext [

	^ self isBlockContext
		  ifTrue: [ self parent methodContext ]
		  ifFalse: [ self ]
]

{ #category : #'*DebuggableASTDebugger' }
DASTContext >> namedTempAt: index [
	^ self variablesDict at: (tempVarsNamesIndexes keyAtValue: index)
]

{ #category : #'*DebuggableASTDebugger' }
DASTContext >> tempNamed: aTempVarName [
	^ self variablesDict at: aTempVarName
]

{ #category : #'*DebuggableASTDebugger' }
DASTContext >> tempNames [
	^ variablesDict keys
]

{ #category : #'*DebuggableASTDebugger' }
DASTContext >> top [
	stack ifEmpty: [ ^ #emptyStack ].
	^ stack top
]
