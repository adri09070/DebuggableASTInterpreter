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

{ #category : #initialization }
DASTDebugger >> buildToolbar [

	^ self newToolbar
		  addItem: (SpToolbarButtonPresenter new
				   label: 'Proceed';
				   icon: (self iconNamed: #glamorousSpawn);
				   action: [ self proceed ];
				   yourself);
		  addItem: (SpToolbarButtonPresenter new
				   label: 'Step';
				   icon: (self iconNamed: #down);
				   action: [ self stepInterpreter ];
				   yourself);
		  addItem: (SpToolbarButtonPresenter new
				   label: 'Step over';
				   icon: (self iconNamed: #forward);
				   action: [ self stepOver ];
				   yourself);
		  addItem: (SpToolbarButtonPresenter new
				   label: 'Step through';
				   icon: (self iconNamed: #glamorousThrough);
				   action: [ self stepThrough ];
				   yourself);
		  addItem: (SpToolbarButtonPresenter new
				   label: 'Restart';
				   icon: (self iconNamed: #glamorousRestart);
				   action: [ self restart ];
				   yourself);
		  yourself
]

{ #category : #accessing }
DASTDebugger >> clear [
	simulatorSession terminate
]

{ #category : #layout }
DASTDebugger >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: stack;
		  add: toolBar expand: false;
		  add: code;
		  yourself
]

{ #category : #initialization }
DASTDebugger >> initializePresenters [

	code := self newCode.
	stack := self newList
		         transmitDo: [ :ctx | self updateCodeFromContext: ctx ];
		         yourself.
	toolBar := self buildToolbar.
	self updateStack
]

{ #category : #accessing }
DASTDebugger >> interpreter: aDASTInterpreter [

	interpreter := aDASTInterpreter
]

{ #category : #menu }
DASTDebugger >> proceed [

	interpreter evaluate.
	self updateStack
]

{ #category : #menu }
DASTDebugger >> restart [

	interpreter restart: stack selectedItem.
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

{ #category : #'debug - stepping' }
DASTDebugger >> stepOver [

	interpreter stepOver.
	self updateStack
]

{ #category : #actions }
DASTDebugger >> stepThrough [

	interpreter stepThrough.
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
