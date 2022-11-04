Class {
	#name : #DASTContextTests,
	#superclass : #TestCase,
	#instVars : [
		'context',
		'aCompiledMethod',
		'aReceiver',
		'aSender',
		'anArgument',
		'aMethodContext',
		'pharoContext',
		'interpreterRoot',
		'rootContext',
		'interpreterMethod',
		'methodContext',
		'interpreterBlock',
		'blockContext'
	],
	#category : #'DebuggableASTInterpreter-Tests'
}

{ #category : #helpers }
DASTContextTests >> helperAddingPoints [

	^ (2@2) + (3 @ 3)
]

{ #category : #helpers }
DASTContextTests >> helperCallingHelperAddingPoints [

	^ self helperAddingPoints
]

{ #category : #running }
DASTContextTests >> setUp [

	super setUp.

	"Put here a common initialization logic for tests"
	interpreterRoot := DASTInterpreter new.
	interpreterRoot initializeWithProgram: (RBParser parseExpression: '1').
	rootContext := interpreterRoot currentContext rootContext.

	interpreterMethod := DASTInterpreter new.
	interpreterMethod initializeWithProgram:
		(RBParser parseExpression: '1').
	methodContext := interpreterMethod currentContext.

	interpreterBlock := DASTInterpreter new.
	interpreterBlock initializeWithProgram: (RBParser parseExpression: '1').
	blockContext := interpreterBlock currentContext
]

{ #category : #tests }
DASTContextTests >> testContextInitialization [
	context := DASTContext new.
	self assert: context executedNodes isEmpty
]

{ #category : #tests }
DASTContextTests >> testDASTRootContextAsContext [

	| bcContext |
	self assert: rootContext sender isNil.

	bcContext := rootContext asContext.

	self assert: bcContext isNil
]

{ #category : #stack }
DASTContextTests >> testStackPopEmpty [
	| stack |
	stack := DASTStack new.
	self should: [ stack pop ] raise: Exception
]

{ #category : #stack }
DASTContextTests >> testStackPushPop [
	| stack |
	stack := DASTStack new
		push: 3;
		push: 5;
		yourself.
	self assert: stack pop equals: 5.
	self assert: stack pop equals: 3.
]

{ #category : #stack }
DASTContextTests >> testStackPushTop [
	| stack |
	stack := DASTStack new
		push: 3;
		push: 5;
		yourself.
	self assert: stack top equals: 5.
	self assert: stack pop equals: 5.
	self assert: stack pop equals: 3.
	
]

{ #category : #stack }
DASTContextTests >> testStackPushValueLink [
	| stack |
	stack := DASTStack new
		push: (ValueLink value: 4);
		push: (ValueLink value: nil);
		yourself.
	self assert: stack pop value equals: nil.
	self assert: stack pop value equals: 4.
]
