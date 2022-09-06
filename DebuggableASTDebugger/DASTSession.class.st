"
I model a debug session for the DASTInterpreter debugger. I provide an APIfor debuggers to interact with the underlying debugging model.
"
Class {
	#name : #DASTSession,
	#superclass : #Object,
	#instVars : [
		'interpreter'
	],
	#category : #DebuggableASTDebugger
}

{ #category : #debugging }
DASTSession class >> debug: sourceCode [
	^self new debug: sourceCode
]

{ #category : #'as yet unclassified' }
DASTSession class >> debuggingActionsForPragmas: aSymbolsCollection for: aDebugger [
	^ aSymbolsCollection
		inject: OrderedCollection new
		into: [ :currentActions :aSymbol | 
			{StepOverDebugAction asDebugAction.
			StepIntoDebugAction asDebugAction.
			RestartDebugAction asDebugAction}
				collect: [ :aDebugAction | 
					aDebugAction
						forDebugger: aDebugger;
						yourself ] ]
]

{ #category : #API }
DASTSession >> debug: sourceCode [
	interpreter := DASTInterpreter new.
	interpreter initializeWithProgram: (RBParser parseExpression: sourceCode).
	
]

{ #category : #'accessing context' }
DASTSession >> interpreter [
	^interpreter
]

{ #category : #'accessing context' }
DASTSession >> interruptedContext [
	^interpreter currentContext
]

{ #category : #testing }
DASTSession >> isContextPostMortem: selectedContext [
	self flag: 'For now I do not care...'.
	^false
]

{ #category : #initialization }
DASTSession >> recompileMethodTo: text inContext: aContext notifying: aNotifyer [
	"Oh no... this must be implemented to handle method changes in the debugger.
	See the same method in class DebugSession.
	Have fun."

	self flag: #TODO.
	self halt
]

{ #category : #'as yet unclassified' }
DASTSession >> restart: aDASTContext [
	aDASTContext initialize.
	aDASTContext
		sender: aDASTContext parent;
		receiver: aDASTContext receiver;
		messageNode: aDASTContext messageNode.
	interpreter currentContext: aDASTContext.
	self triggerEvent: #restart
]

{ #category : #'accessing context' }
DASTSession >> selectedCodeRangeForContext: aContext [
	^ aContext currentNode start to: aContext currentNode stop
]

{ #category : #'accessing context' }
DASTSession >> stack [
	| stack context |
	stack := OrderedCollection new.
	context := self interruptedContext.
	stack add: context.
	[ context isRoot ]
		whileFalse: [ context := context parent.
			stack add: context ].
	^ stack reject:[:ctx| ctx isRoot]
]

{ #category : #'accessing context' }
DASTSession >> stackOfSize: anInteger [
	| stack context |
	stack := OrderedCollection new.
	context := self interruptedContext.
	stack add: context.
	[ context isRoot ]
		whileFalse: [ context := context parent.
			stack add: context ].
	^ stack reject:[:ctx| ctx isRoot]
]

{ #category : #'accessing context' }
DASTSession >> stepInto [
	interpreter stepInto
]

{ #category : #'as yet unclassified' }
DASTSession >> stepInto: aDASTContext [ 
	self stepInto.
	self triggerEvent: #stepInto
]

{ #category : #'accessing context' }
DASTSession >> stepOver [
	interpreter stepOver.
	self triggerEvent: #stepOver
]

{ #category : #'as yet unclassified' }
DASTSession >> stepOver: aDASTContext [ 
	self stepOver
]

{ #category : #'as yet unclassified' }
DASTSession >> terminate [
]

{ #category : #'as yet unclassified' }
DASTSession >> triggerEvent: anEventSelector [
	"Evaluate all actions registered for <anEventSelector>. Return the value of the last registered action."

    ^(self actionForEvent: anEventSelector) value
]
