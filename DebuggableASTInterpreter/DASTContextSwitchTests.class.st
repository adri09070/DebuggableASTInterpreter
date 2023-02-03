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
DASTContextSwitchTests >> testInterpreterSwitchKeepsBindings [

	| dastContext |
	4 timesRepeat: [ context := context step ].
	self
		assert: ((context lookupTempVar: #a) readInContext: context)
		equals: 40.
	self
		assert: ((context lookupTempVar: #b) readInContext: context)
		equals: 2.

	dastContext := context asDASTContextInterpretedBy:
		               DASTInterpreter new.
	self assert: (dastContext findLocalVariable: #a) value equals: 40.
	self assert: (dastContext findLocalVariable: #b) value equals: 2
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitchKeepsBindingsRecursively [

	| dastContext tempNames |
	4 timesRepeat: [ context := context step ].
	dastContext := context asDASTContextInterpretedBy:
		               DASTInterpreter new.

	[ dastContext isRoot ] whileFalse: [
		tempNames := context tempNames.
		tempNames do: [ :temp |
			self
				assert: ((context lookupTempVar: temp) readInContext: context)
				identicalTo: (dastContext findLocalVariable: temp) value ].
		context := context sender.
		dastContext := dastContext sender ]
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitchKeepsReceiver [

	| dastContext |
	4 timesRepeat: [ context := context step ].

	dastContext := context asDASTContextInterpretedBy:
		               DASTInterpreter new.
	self assert: context receiver identicalTo: dastContext receiver
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitchKeepsReceiversRecursively [

	| dastContext |
	4 timesRepeat: [ context := context step ].
	dastContext := context asDASTContextInterpretedBy:
		               DASTInterpreter new.

	[ dastContext isRoot ] whileFalse: [
		self assert: context receiver identicalTo: dastContext receiver.
		context := context sender.
		dastContext := dastContext sender ]
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitchReceiverRemainsUnchanged [

	| dastContext instVars oldInstVarValues newInstVarValues |
	4 timesRepeat: [ context := context step ].

	instVars := context receiver class allInstVarNames.
	oldInstVarValues := instVars collect: [ :inst |
		                    context receiver instVarNamed: inst ].

	dastContext := context asDASTContextInterpretedBy:
		               DASTInterpreter new.

	newInstVarValues := instVars collect: [ :inst |
		                    dastContext receiver instVarNamed: inst ].

	oldInstVarValues withIndexDo: [ :each :index |
		self assert: each identicalTo: (newInstVarValues at: index) ]
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitchTopNodeIsNodeMappedToCurrentPC [

	| dastContext pc node |
	4 timesRepeat: [ context := context step ].

	pc := context pc.
	dastContext := context asDASTContextInterpretedBy:
		               DASTInterpreter new.
	node := context compiledCode sourceNodeForPC: context pc.

	self assert: dastContext nodes top identicalTo: node
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitchTopNodeIsNodeMappedToCurrentPCRecursively [

	| dastContext pcs node |
	4 timesRepeat: [ context := context step ].

	pcs := context stack collect: [ :ctx | ctx pc ].
	dastContext := context asDASTContextInterpretedBy:
		               DASTInterpreter new.

	[ dastContext isRoot ] whileFalse: [
		node := context compiledCode sourceNodeForPC: context pc.

		self assert: dastContext nodes top identicalTo: node.
		context := context sender.
		dastContext := dastContext sender ]
]
