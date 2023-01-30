Class {
	#name : #DASTNoMethod,
	#superclass : #DASTMethod,
	#category : #'DebuggableASTInterpreter-Closures'
}

{ #category : #testing }
DASTNoMethod >> isNoMethod [

	^ true
]

{ #category : #accessing }
DASTNoMethod >> nodeAST: aRBNode [

	super nodeAST: aRBNode.
	nodeAST doSemanticAnalysis
]
