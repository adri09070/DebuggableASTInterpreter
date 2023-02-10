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
	"context terminate."
	super tearDown.
	
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitchCurrentNodeIsLastExecutedNode [

	| dastContext node |
	4 timesRepeat: [ context := context step ].

	dastContext := context asDASTContextInterpretedBy:
		               DASTInterpreter new.

	node := dastContext executedNodes last.

	self assert: dastContext currentNode identicalTo: node
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
DASTContextSwitchTests >> testInterpreterSwitchKeepsValueStack [

	| dastContext |
	6 timesRepeat: [ context := context step ].

	dastContext := context asDASTContextInterpretedBy:
		               DASTInterpreter new.
	self
		assert: dastContext stack size
		equals: context stackPtr - context numTemps.
	(Interval from: 1 to: dastContext stack size) do: [ :index |
		self
			assert: (dastContext stack at: index)
			identicalTo: (context at: context numTemps + index) ]
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitchKeepsValueStackRecursively [

	| dastContext |
	6 timesRepeat: [ context := context step ].

	dastContext := context asDASTContextInterpretedBy:
		               DASTInterpreter new.

	[ dastContext isRoot ] whileFalse: [
		self
			assert: dastContext stack size
			equals: context stackPtr - context numTemps.
		(Interval from: 1 to: dastContext stack size) do: [ :index |
			self
				assert: (dastContext stack at: index)
				identicalTo: (context at: context numTemps + index) ].
		context := context sender.
		dastContext := dastContext sender ]
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitchMessageNodeIsLastSourceNodeExecutedFromSender [

	| dastContext node |
	4 timesRepeat: [ context := context step ].

	dastContext := context asDASTContextInterpretedBy:
		               DASTInterpreter new.

	self deny: dastContext sender isRoot.
	node := context sender sourceNodeExecuted.

	self assert: dastContext messageNode identicalTo: node
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitchPutsRootBeforeFirstInterestingContext [

	| dastContext |
	4 timesRepeat: [ context step ].

	dastContext := context asDASTContextInterpretedBy:
		               DASTInterpreter new.

	self deny: dastContext isRoot.
	self deny: dastContext isBlockContext.
	self
		assert: dastContext methodOrBlock compiledCode
		identicalTo: context compiledCode.

	self deny: dastContext sender isRoot.
	self assert: dastContext sender isBlockContext.
	self
		assert: dastContext sender methodOrBlock nodeAST
		equals: context sender compiledCode ast.

	self assert: dastContext sender sender isRoot
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
DASTContextSwitchTests >> testInterpreterSwitchStepIsCorrect [

	| dastContext pc node interpreter |
	4 timesRepeat: [ context := context step ].

	pc := context pc.
	dastContext := context asDASTContextInterpretedBy:
		               (interpreter := DASTInterpreter new).
	node := context compiledCode sourceNodeForPC: context pc.

	interpreter initializeWithContext: dastContext.

	self assert: dastContext nodes top identicalTo: node.
	self assert: dastContext canExecute.
	self assert: interpreter currentContext identicalTo: dastContext.

	"one step to evaluate a (40), one step to evaluate b (2) and one step to compute the sum"
	interpreter
		stepInto;
		stepInto;
		stepInto.

	self assert: dastContext nodes top isReturn.
	self assert: dastContext canExecute.
	self assert: interpreter currentContext identicalTo: dastContext
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
