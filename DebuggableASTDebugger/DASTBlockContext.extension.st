Extension { #name : #DASTBlockContext }

{ #category : #'*DebuggableASTDebugger' }
DASTBlockContext >> tempNamed: aTempVarName [

	^ [ super tempNamed: aTempVarName ]
		  on: KeyNotFound
		  do: [
			  [
			  self sender
				  ifNotNil: [ self sender tempNamed: aTempVarName ]
				  ifNil: [ closure outerContext tempNamed: aTempVarName ] ]
				  on: KeyNotFound
				  do: [ closure outerContext tempNamed: aTempVarName ] ]
]
