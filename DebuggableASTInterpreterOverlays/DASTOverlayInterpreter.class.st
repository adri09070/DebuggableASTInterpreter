"
Experimental.
The DASTOverlayInterpreter uses ""overlays"" when reading and writing to object to debug a program in isolation. That version uses a local dictionary as a global object overlay.
"
Class {
	#name : #DASTOverlayInterpreter,
	#superclass : #DASTInterpreter,
	#instVars : [
		'objectStateOverlay',
		'overlayCounter',
		'overlaysForPC'
	],
	#category : #'DebuggableASTInterpreterOverlays-Interpreter - version'
}

{ #category : #accessing }
DASTOverlayInterpreter >> nextOverlayCounter [
	overlayCounter := self overlayCounter + 1.
	^ overlayCounter
]

{ #category : #accessing }
DASTOverlayInterpreter >> objectStateOverlay [
	^ objectStateOverlay
		ifNil: [ objectStateOverlay := IdentityDictionary new ]
]

{ #category : #accessing }
DASTOverlayInterpreter >> overlayCounter [
	^overlayCounter ifNil:[overlayCounter := 0]
]

{ #category : #visiting }
DASTOverlayInterpreter >> overlayFor: anObject [
	^ self objectStateOverlay
		at: anObject
		ifAbsentPut: [ ObjectOverlay on: anObject ]
]

{ #category : #visiting }
DASTOverlayInterpreter >> overlaysForPC [
	^ overlaysForPC ifNil: [ overlaysForPC := Dictionary new ]
]

{ #category : #visiting }
DASTOverlayInterpreter >> readInstanceVariableNamed: name [

	^ self readInstanceVariableNamed: name for: self receiver
]

{ #category : #visiting }
DASTOverlayInterpreter >> readInstanceVariableNamed: name for: object [
	^ (self overlayFor: object)
		readInstanceVariableNamed: name
		ifAbsent: [ ^ super readInstanceVariableNamed: name ]
]

{ #category : #visiting }
DASTOverlayInterpreter >> registerOverlayForCurrentPC: overlay [
	self overlaysForPC at: self overlayCounter put: overlay
]

{ #category : #visiting }
DASTOverlayInterpreter >> write: value toInstVarNamed: name [
	| overlay |
	overlay := self overlayFor: self receiver.
	overlay
		write: value
		toInstVarNamed: name
		fromNode: self currentNode parent
		inContext: self currentContext.
	overlay overlayProgramCounter: self nextOverlayCounter.
	self registerOverlayForCurrentPC: overlay
]
