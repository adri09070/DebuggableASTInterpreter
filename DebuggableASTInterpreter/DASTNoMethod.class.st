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
	"Not necessary anymore as the interpreter compiles DoIts properly"
	"nodeAST doSemanticAnalysis"
]
