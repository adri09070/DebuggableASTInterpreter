Class {
	#name : 'StSwitchToDASTCommand',
	#superclass : 'StDebuggerCommand',
	#category : 'DebuggableASTDebuggerExperiment',
	#package : 'DebuggableASTDebuggerExperiment'
}

{ #category : 'initialization' }
StSwitchToDASTCommand class >> defaultIconName [

	^ #halt
]

{ #category : 'initialization' }
StSwitchToDASTCommand class >> defaultShortcut [

	^ $d meta , $s meta
]

{ #category : 'executing' }
StSwitchToDASTCommand >> execute [

	| session |
	session := self context session.
	self context programmaticallyClose.
	(OupsDebugRequest newForContext: context)
		label: session interruptedContext compiledCode printString;
		exception: (DASTException fromSignallerContext: session interruptedContext);
		"DASTDebugger debugSession: session"submit
]
