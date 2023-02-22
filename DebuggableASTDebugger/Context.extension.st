Extension { #name : #Context }

{ #category : #'*DebuggableASTDebugger' }
Context >> dastValueFor: anObject interpretedBy: aDASTInterpreter withClosureToBlockDictionary: closureToDASTBlock [

	| value |
	(closureToDASTBlock includesKey: anObject) ifTrue: [
		^ closureToDASTBlock at: anObject ].
	value := anObject bcToDASTValue.
	value isBlock ifTrue: [
		value outerContext: self. "aDASTInterpreter currentContext"
		closureToDASTBlock at: anObject put: value ].
	^ value
]
