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

{ #category : #'tests - helper' }
DASTContextSwitchTests >> assertFullBlock: fullBlock equalsDASTBlock: dastBlock [

	| closure |
	self assert: fullBlock isClosure.
	self assert: dastBlock isBlock.
	closure := dastBlock closure.
	^ self
		  assert: fullBlock compiledBlock
		  identicalTo: closure compiledBlock;
		  assert: fullBlock outerContext identicalTo: closure outerContext;
		  assert: fullBlock receiver identicalTo: closure receiver
]

{ #category : #'tests - helper' }
DASTContextSwitchTests >> bcStepUntil: aBlock [

	aBlock whileTrue: [ context := context step ]
]

{ #category : #'tests - helper' }
DASTContextSwitchTests >> dastStepUntil: aBlock [

	aBlock whileTrue: [ dastInterpreter stepInto ].
	dastContext := dastInterpreter currentContext
]

{ #category : #'tests - helper' }
DASTContextSwitchTests >> interpreterOnMethodWithTempVector [

	dastInterpreter initializeWithProgram:
		(RBParser parseExpression: '| debuggerObjectForTest block a b | 
				debuggerObjectForTest := StDebuggerObjectForTests new. 
				a := 0.
				block := [ | c | debuggerObjectForTest methodWithTempsAssignments. 1=2 ifTrue: [ block value ]. a := a + 1. b:=0. c:=0 . [ a:= a + 2. c:=c+4. b:=b+3 ] value ].
				^ block value + b + a').

	dastContext := dastInterpreter currentContext
]

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
]

{ #category : #running }
DASTContextSwitchTests >> tearDown [
	"context terminate."

	super tearDown.
	context := nil.
	dastContext := nil.
	dastInterpreter := nil
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchBottomContextMapsToRootAndTerminatesProcess [

	| process |
	4 timesRepeat: [ dastInterpreter stepInto ].

	context := dastContext asContext.

	[ dastContext isRoot ] whileFalse: [
		dastContext := dastContext sender.
		context := context sender ].

	self assert: context sender isNil.

	process := Process
		           forContext: context
		           priority: Processor userInterruptPriority.

	self deny: process isTerminated.
	self shouldnt: [ process resume ] raise: BlockCannotReturn.
	self assert: process isTerminated
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchCurrentPcIsFirstPcOfTopNodeOnStack [

	| node |
	4 timesRepeat: [ dastInterpreter stepInto ].

	context := dastContext asContext.

	node := dastContext nodes top.

	self
		assert: context pc
		identicalTo:
		(dastContext methodOrBlock nodeAST firstPcForNode: node)
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchCurrentPcIsFirstPcOfTopNodeOnStackRecursively [

	| node |
	4 timesRepeat: [ dastInterpreter stepInto ].
	node := dastContext nodes top.

	context := dastContext asContext.

	[ dastContext isRoot ] whileFalse: [
		node := dastContext nodes top.

		self
			assert: context pc
			identicalTo:
			(dastContext methodOrBlock nodeAST firstPcForNode: node).
		context := context sender.
		dastContext := dastContext sender ]
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchKeepsBindings [
	"we step after the node `b := 2  ` of StDebuggerObjectForTests>>#methodWithTempsAssignments has been executed"

	4 timesRepeat: [ dastInterpreter stepInto ].
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

	"The test fails because I don't manage to get a compiled block (and thus a block closure) that contains the bindings of variables from the outer context. I suppose there are something to do with the compiler. I tried to compile the block in the DAST outer context but it doesn't work (DNU). I don't know if defining these messages would solve the problem"

	| tempNames dastTemp |
	4 timesRepeat: [ dastInterpreter stepInto ].

	context := dastContext asContext.

	[ dastContext isRoot ] whileFalse: [
		tempNames := dastContext allTemps collect: [ :each | each key ].
		tempNames do: [ :temp |
			dastTemp := (dastContext findLocalVariable: temp) value.
			dastTemp isBlock
				ifFalse: [
					self
						assert: ((context lookupTempVar: temp) readInContext: context)
						identicalTo: dastTemp ]
				ifTrue: [
					| contextTemp |
					contextTemp := (context lookupTempVar: temp) readInContext:
						               context.
					self assertFullBlock: contextTemp equalsDASTBlock: dastTemp ] ].
		context := context sender.
		dastContext := dastContext sender ]
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchKeepsReceiver [

	4 timesRepeat: [ dastInterpreter stepInto ].

	context := dastContext asContext.
	self assert: context receiver identicalTo: dastContext receiver
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchKeepsReceiversRecursively [

	4 timesRepeat: [ dastInterpreter stepInto ].
	context := dastContext asContext.

	[ dastContext isRoot ] whileFalse: [
		self assert: context receiver identicalTo: dastContext receiver.
		context := context sender.
		dastContext := dastContext sender ]
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchKeepsValueStack [

	| stack |
	4 timesRepeat: [ dastInterpreter stepInto ].
	stack := dastContext stack.

	context := dastContext asContext.

	self
		assert: context stackPtr
		equals: dastContext allTemps size + stack size.
	self assert: dastContext allTemps size equals: context numTemps.
	(Interval from: 1 to: stack size) do: [ :index |
		self
			assert: (dastContext stack at: index)
			identicalTo: (context at: context numTemps + index) ].
	(Interval from: 1 to: dastContext allTemps size) do: [ :index |
		self
			assert: (context at: index)
			identicalTo: (dastContext allTemps at: index) value ]
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchKeepsValueStackRecursively [

	| stack dastElement contextElement |
	"The test fails because a block context relies on its variable dict to build the new context's stack, instead of allTemps. Maybe (Surely) that my approach of using allTemps is wrong but this block context needs at least a vector of temps from allTemps."
	4 timesRepeat: [ dastInterpreter stepInto ].
	context := dastContext asContext.

	[ dastContext isRoot ] whileFalse: [
		stack := dastContext stack.

		self
			assert: context stackPtr
			equals: dastContext ir tempMap size + stack size.
		self assert: dastContext ir tempMap size equals: context numTemps.
		(Interval from: 1 to: stack size) do: [ :index |
			dastElement := dastContext stack at: index.
			contextElement := context at: context numTemps + index.
			dastElement isBlock
				ifFalse: [ self assert: contextElement identicalTo: dastElement ]
				ifTrue: [
				self assertFullBlock: contextElement equalsDASTBlock: dastElement ] ].
		(Interval from: 1 to: dastContext ir tempMap size) do: [ :index |
			contextElement := context at: index.
			dastElement := (dastContext tempNamed:
				                (dastContext allTemps at: index) key) value.
			dastElement isBlock
				ifFalse: [ self assert: contextElement identicalTo: dastElement ]
				ifTrue: [
				self assertFullBlock: contextElement equalsDASTBlock: dastElement ] ].
		dastContext := dastContext sender.
		context := context sender ]
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchProcessResume [

	| process |
	context := dastContext asContext.

	process := Process
		           forContext: context
		           priority: Processor userInterruptPriority.

	[ dastContext isRoot ] whileFalse: [
		context := context sender.
		dastContext := dastContext sender ].

	process completeTo: context.

	self assert: process suspendedContext top equals: 42.

	self deny: process isTerminated.

	self shouldnt: [ process resume ] raise: BlockCannotReturn.

	self assert: process isTerminated
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchReceiverRemainsUnchanged [

	| instVars oldInstVarValues newInstVarValues |
	4 timesRepeat: [ dastInterpreter stepInto ].

	instVars := dastContext receiver class allInstVarNames.
	oldInstVarValues := instVars collect: [ :inst |
		                    dastContext receiver instVarNamed: inst ].

	context := dastContext asContext.

	newInstVarValues := instVars collect: [ :inst |
		                    context receiver instVarNamed: inst ].

	oldInstVarValues withIndexDo: [ :each :index |
		self assert: each identicalTo: (newInstVarValues at: index) ]
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchStepIsCorrect [

	| pc node process |
	4 timesRepeat: [ dastInterpreter stepInto ].

	node := dastContext nodes top.
	context := dastContext asContext.
	pc := dastContext methodOrBlock nodeAST firstPcForNode: node.

	process := Process
		           forContext: context
		           priority: Processor userInterruptPriority.

	self assert: process suspendedContext pc identicalTo: pc.
	self deny: context isDead.
	self assert: process suspendedContext identicalTo: context.

	"one step to evaluate a (40), one step to evaluate b (2) and one step to compute the sum"
	process
		step;
		step;
		step.

	self assert: process suspendedContext top equals: 42.
	self assert: (process suspendedContext compiledCode sourceNodeForPC:
			 process suspendedContext pc) isReturn.
	self deny: process suspendedContext isDead.
	self assert: process suspendedContext identicalTo: context
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchTempVectorBindings [

	| dastTemp  |
	self
		interpreterOnMethodWithTempVector;
		dastStepUntil: [
			(dastInterpreter currentNode isMessage and: [
					 dastInterpreter currentNode selector = #+ and: [
							 dastInterpreter currentNode arguments last isLiteralNode and: [
									 dastInterpreter currentNode arguments last value = 3 ] ] ])
				not ].
	dastContext := dastInterpreter currentContext.

	context := dastContext asContext.

	[ dastContext isRoot ] whileFalse: [
		| tempNames |
		tempNames := dastContext allTemps collect: [ :each | each key ].
		tempNames do: [ :temp |
			dastTemp := (dastContext findLocalVariable: temp) value.
			dastTemp isBlock
				ifFalse: [
					self
						assert: ((context lookupTempVar: temp) readInContext: context)
						identicalTo: dastTemp ]
				ifTrue: [
					| contextTemp |
					contextTemp := (context lookupTempVar: temp) readInContext:
						               context.
					self assertFullBlock: contextTemp equalsDASTBlock: dastTemp ] ].

		dastContext := dastContext sender.
		context := context sender ]
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchTempVectorCreation [

	| astScope temp dastTemp vectorSize |
	self
		interpreterOnMethodWithTempVector;
		dastStepUntil: [
			(dastInterpreter currentNode isMessage and: [
					 dastInterpreter currentNode selector = #+ and: [
							 dastInterpreter currentNode arguments last isLiteralNode and: [
									 dastInterpreter currentNode arguments last value = 3 ] ] ])
				not ].
	dastContext := dastInterpreter currentContext.

	context := dastContext asContext.

	[ dastContext isRoot ] whileFalse: [ "ir := dastContext ir."
		astScope := dastContext methodOrBlock nodeAST scope.
		astScope tempVector ifNotEmpty: [
			temp := context tempNamed: astScope tempVectorName.
			self assert: temp isArray.
			vectorSize := 0.
			astScope tempVector keysDo: [ :each |
				vectorSize := vectorSize + 1.
				dastTemp := dastContext tempNamed: each.
				dastTemp isBlock
					ifFalse: [
					self assert: (temp at: vectorSize) identicalTo: dastTemp ]
					ifTrue: [
						self
							assertFullBlock: (temp at: vectorSize)
							equalsDASTBlock: dastTemp ] ] ].

		dastContext := dastContext sender.
		context := context sender ]
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchTempVectorProcessResume [

	| process |
	self
		interpreterOnMethodWithTempVector;
		dastStepUntil: [
			(dastInterpreter currentNode isMessage and: [
					 dastInterpreter currentNode selector = #+ and: [
							 dastInterpreter currentNode arguments last isLiteralNode and: [
									 dastInterpreter currentNode arguments last value = 3 ] ] ])
				not ].
	dastContext := dastInterpreter currentContext.

	context := dastContext asContext.

	process := Process
		           forContext: context
		           priority: Processor userInterruptPriority.

	[ dastContext isRoot ] whileFalse: [
		context := context sender.
		dastContext := dastContext sender ].

	process completeTo: context.

	self assert: process suspendedContext top equals: 9.

	self deny: process isTerminated.

	self shouldnt: [ process resume ] raise: Exception.

	self assert: process isTerminated
]

{ #category : #tests }
DASTContextSwitchTests >> testBytecodeSwitchTempVectorStack [

	| stack dastElement contextElement |
	self
		interpreterOnMethodWithTempVector;
		dastStepUntil: [
			(dastInterpreter currentNode isMessage and: [
					 dastInterpreter currentNode selector = #+ and: [
							 dastInterpreter currentNode arguments last isLiteralNode and: [
									 dastInterpreter currentNode arguments last value = 3 ] ] ])
				not ].
	dastContext := dastInterpreter currentContext.

	context := dastContext asContext.

	[ dastContext isRoot ] whileFalse: [
		stack := dastContext stack.

		self
			assert: context stackPtr
			equals: dastContext ir tempMap size + stack size.
		self assert: dastContext ir tempMap size equals: context numTemps.
		(Interval from: 1 to: stack size) do: [ :index |
			dastElement := dastContext stack at: index.
			contextElement := context at: context numTemps + index.
			dastElement isBlock
				ifFalse: [ self assert: contextElement identicalTo: dastElement ]
				ifTrue: [
				self assertFullBlock: contextElement equalsDASTBlock: dastElement ] ].
		(Interval from: 1 to: dastContext ir tempMap size) do: [ :index |
			| variableNames |
			variableNames := (dastContext ir tempMap associations sorted: [
				                  :assoc1
				                  :assoc2 | assoc1 value <= assoc2 value ])
				                 collect: [ :each | each key ].
			contextElement := context at: index.
			(variableNames at: index) = (dastContext allTemps at: index) key
				ifTrue: [
					dastElement := (dastContext tempNamed:
						                (dastContext allTemps at: index) key) value.
					dastElement isBlock
						ifFalse: [ self assert: contextElement identicalTo: dastElement ]
						ifTrue: [
						self
							assertFullBlock: contextElement
							equalsDASTBlock: dastElement ] ]
				ifFalse: [
					| astScope |
					astScope := context compiledCode ast scope.
					self assert: contextElement isArray.
					astScope tempVectorName = (variableNames at: index)
						ifTrue: [
							astScope tempVectorVarNames withIndexDo: [ :each :indexVector |
								dastElement := (dastContext tempNamed: each) value.
								dastElement isBlock
									ifFalse: [
										self
											assert: (contextElement at: indexVector)
											identicalTo: dastElement ]
									ifTrue: [
										self
											assertFullBlock: (contextElement at: indexVector)
											equalsDASTBlock: dastElement ] ] ]
						ifFalse: [
							self
								assert: contextElement
								identicalTo:
								(context sender tempNamed: (variableNames at: index)) ] ] ].

		dastContext := dastContext sender.
		context := context sender ]
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
