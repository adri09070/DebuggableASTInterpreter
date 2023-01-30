Class {
	#name : #DASTDebugger,
	#superclass : #SpPresenter,
	#traits : 'TDebugger',
	#classTraits : 'TDebugger classTrait',
	#instVars : [
		'stack',
		'code',
		'interpreter',
		'toolBar',
		'simulatorSession'
	],
	#category : #DebuggableASTDebugger
}

{ #category : #'instance creation' }
DASTDebugger class >> debugSession: aDebugSession [

	| dast |
	dast := self basicNew.
	dast simulatorSession: aDebugSession.
	dast interpreter:
		(DASTInterpreter startFromContext: aDebugSession interruptedContext).
	dast initialize.
	dast open
]

{ #category : #accessing }
DASTDebugger >> clear [
	simulatorSession terminate
]

{ #category : #initialization }
DASTDebugger >> initializePresenters [

	code := self newCode.
	stack := self newList
		         transmitDo: [ :ctx | self updateCodeFromContext: ctx ];
		         yourself.
	toolBar := self newToolbar
		           addItem: (SpToolbarButtonPresenter new
				            label: 'Step';
				            icon: (self iconNamed: #smallOk);
				            action: [ self stepInterpreter ];
				            yourself);
		           yourself.
	self updateStack
]

{ #category : #accessing }
DASTDebugger >> simulatorSession: anObject [

	simulatorSession := anObject
]

{ #category : #'as yet unclassified' }
DASTDebugger >> stepInterpreter [


	interpreter stepInto.
	self updateStack
]

{ #category : #'presenter - code' }
DASTDebugger >> updateCodeFromContext: aDASTContext [

	aDASTContext ifNil: [ ^ nil ].
	code text: aDASTContext sourceCode.
	code beForContext: aDASTContext.
	 code removeAllTextSegmentDecorations.

	 code addTextSegmentDecoration: (SpTextPresenterDecorator forHighlight
		interval: (aDASTContext currentNode start  to: aDASTContext currentNode stop + 1);
		yourself).
		
]

{ #category : #'as yet unclassified' }
DASTDebugger >> updateStack [

	stack
		items: interpreter contextsStack;
		selectFirst
]
