Class {
	#name : #DASTContextSwitchTests,
	#superclass : #TestCase,
	#instVars : [
		'context'
	],
	#category : #'DebuggableASTInterpreter-Tests'
}

{ #category : #running }
DASTContextSwitchTests >> setUp [
	| debuggerObjectForTest |
	super setUp.
	debuggerObjectForTest := StDebuggerObjectForTests new.
	context := [  debuggerObjectForTest methodWithTempsAssignments ] asContext.
	2 timesRepeat: [ context := context step ]
	
	"Put here a common initialization logic for tests"
]

{ #category : #running }
DASTContextSwitchTests >> tearDown [
	context terminate.
	super tearDown.
	
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitch [
	| dastContext |
	4 timesRepeat: [ context := context step ].
	self assert: ((context lookupTempVar: #a) readInContext: context) equals: 40.
	self assert: ((context lookupTempVar: #b) readInContext: context) equals: 2.
	
	dastContext := context asDASTContextInterpretedBy: DASTInterpreter new.
"	self assert: (dastContext findLocalVariable: #a) value equals: 40"
	
	
]
