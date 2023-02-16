Class {
	#name : #DASTContextSwitchTests,
	#superclass : #TestCase,
	#instVars : [
		'context',
		'dastInterpreter',
		'dastContext'
	],
	#category : #'DebuggableASTInterpreter-Tests'
}

{ #category : #running }
DASTContextSwitchTests >> setUp [

	| debuggerObjectForTest |
	super setUp.
	"context initialization"
	debuggerObjectForTest := StDebuggerObjectForTests new.
	context := [ debuggerObjectForTest methodWithTempsAssignments ]
		           asContext.
	2 timesRepeat: [ context := context step ].

	"DASTInterpreter initialization (which initializes DAST contexts)"
	dastInterpreter := DASTInterpreter new.
	dastInterpreter initializeWithProgram:
		(RBParser parseExpression: '| debuggerObjectForTest block | 
				debuggerObjectForTest := StDebuggerObjectForTests new. 
				block := [ debuggerObjectForTest methodWithTempsAssignments ]. 
				block value').
	"We step until we step into StDebuggerObjectForTests>>#methodWithTempsAssignments"
	8 timesRepeat: [ dastInterpreter stepOver ].
	5 timesRepeat: [ dastInterpreter stepInto ].
	dastContext := dastInterpreter currentContext

	"Put here a common initialization logic for tests"
]

{ #category : #running }
DASTContextSwitchTests >> tearDown [
	"context terminate."
	super tearDown.
	
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchKeepsBindings [
	"we step after the node `b := 2  ` of StDebuggerObjectForTests>>#methodWithTempsAssignments has been executed"

	6 timesRepeat: [ dastInterpreter stepInto ].
	self assert: (dastContext findLocalVariable: #a) value equals: 40.
	self assert: (dastContext findLocalVariable: #b) value equals: 2.

	context := dastContext asContext.

	self
		assert: ((context lookupTempVar: #a) readInContext: context)
		equals: 40.
	self
		assert: ((context lookupTempVar: #b) readInContext: context)
		equals: 2
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchKeepsBindingsRecursively [
	"we step after the node `b := 2  ` of StDebuggerObjectForTests>>#methodWithTempsAssignments has been executed"

	"The test fails because the AST of the compiled DoItMethod has a scope with nil indexes for each temp"

	| tempNames dastReceiver |
	6 timesRepeat: [ dastInterpreter stepInto ].

	context := dastContext asContext.

	[ dastContext isRoot ] whileFalse: [
		tempNames := dastContext tempNames.
		tempNames do: [ :temp |
			dastReceiver := (dastContext findLocalVariable: temp) value.
			dastReceiver isBlock
				ifFalse: [
					self
						assert: ((context lookupTempVar: temp) readInContext: context)
						identicalTo: dastReceiver ]
				ifTrue: [
					self
						assert: (dastContext findLocalVariable: temp) value
						identicalTo: dastReceiver nodeAST evaluate ] ].
		context := context sender.
		dastContext := dastContext sender ]
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchKeepsReceiver [

	6 timesRepeat: [ dastInterpreter stepInto ].

	context := dastContext asContext.
	self assert: context receiver identicalTo: dastContext receiver
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchKeepsReceiversRecursively [

	6 timesRepeat: [ dastInterpreter stepInto ].
	context := dastContext asContext.

	[ dastContext isRoot ] whileFalse: [
		self assert: context receiver identicalTo: dastContext receiver.
		context := context sender.
		dastContext := dastContext sender ]
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitchCurrentNodeIsLastExecutedNode [

	| node |
	4 timesRepeat: [ context := context step ].

	dastContext := context asDASTContextInterpretedBy:
		               DASTInterpreter new.

	node := dastContext executedNodes last.

	self assert: dastContext currentNode identicalTo: node
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitchEvaluateAfterSwitchCanFindBindingsOfObjectsDefinedOutsideOfClosuresInContextThatDoesNotHaveDASTEquivalent [

	| debuggerObjectForTest interpreter |
	debuggerObjectForTest := StDebuggerObjectForTests new.
	context := [ debuggerObjectForTest methodWithTempsAssignments ]
		           asContext.
	interpreter := DASTInterpreter new.
	dastContext := context asDASTContextInterpretedBy: interpreter.
	interpreter initializeWithContext: dastContext.

	self assert: interpreter evaluate equals: 42
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitchKeepsBindings [

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

	| tempNames |
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

	4 timesRepeat: [ context := context step ].

	dastContext := context asDASTContextInterpretedBy:
		               DASTInterpreter new.
	self assert: context receiver identicalTo: dastContext receiver
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitchKeepsReceiversRecursively [

	self skip.
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

	| node |
	4 timesRepeat: [ context := context step ].

	dastContext := context asDASTContextInterpretedBy:
		               DASTInterpreter new.

	self deny: dastContext sender isRoot.
	node := context sender sourceNodeExecuted.

	self assert: dastContext messageNode identicalTo: node
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitchPutsRootBeforeFirstInterestingContext [

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

	| instVars oldInstVarValues newInstVarValues |
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

	| pc node interpreter |
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

	| pc node |
	4 timesRepeat: [ context := context step ].

	pc := context pc.
	dastContext := context asDASTContextInterpretedBy:
		               DASTInterpreter new.
	node := context compiledCode sourceNodeForPC: context pc.

	self assert: dastContext nodes top identicalTo: node
]

{ #category : #tests }
DASTContextSwitchTests >> testInterpreterSwitchTopNodeIsNodeMappedToCurrentPCRecursively [

	| pcs node |
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
