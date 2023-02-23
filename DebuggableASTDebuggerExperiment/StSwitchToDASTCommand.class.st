Class {
	#name : #StSwitchToDASTCommand,
	#superclass : #StDebuggerCommand,
	#category : #DebuggableASTDebuggerExperiment
}

{ #category : #initialization }
StSwitchToDASTCommand class >> defaultIconName [

	^ #halt
]

{ #category : #initialization }
StSwitchToDASTCommand class >> defaultShortcut [

	^ $d meta , $s meta
]

{ #category : #execution }
StSwitchToDASTCommand >> execute [

	| session |
	session := self context session.
	self context programmaticallyClose.
	(OupsDebugRequest newForContext: context)
		label: context compiledCode printString;
		exception: (DASTException new
				 signaler: self context session receiver;
				 yourself);
		"DASTDebugger debugSession: session"submit
]
