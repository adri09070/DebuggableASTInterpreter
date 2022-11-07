Class {
	#name : #DASTContextTests,
	#superclass : #TestCase,
	#instVars : [
		'context',
		'aCompiledMethod',
		'aReceiver',
		'aSender',
		'anArgument',
		'aMethodContext',
		'pharoContext',
		'interpreterRoot',
		'rootContext',
		'interpreterMethod',
		'methodContext',
		'interpreterBlock',
		'blockContext'
	],
	#category : #'DebuggableASTInterpreter-Tests'
}

{ #category : #running }
DASTContextTests >> setUp [

	super setUp.

	"Put here a common initialization logic for tests"
	interpreterRoot := DASTInterpreter new.
	interpreterRoot initializeWithProgram:
		(RBParser parseExpression: '1').
	rootContext := interpreterRoot currentContext rootContext.

	interpreterMethod := DASTInterpreter new.
	interpreterMethod initializeWithProgram: (RBParser parseExpression:
			 'DASTInterpreterClassForTests new helperCallingHelperAddingPoints: 2@2 with: 3@3 ').
	interpreterMethod
		stepOver;
		stepOver;
		stepOver;
		stepOver;
		stepInto;
		stepOver;
		stepOver;
		stepOver;
		stepInto;
		stepOver;
		stepOver;
		stepOver;
		stepInto.
	"stop at the beginning of helperMethodAddingPoints context"
	methodContext := interpreterMethod currentContext.

	interpreterBlock := DASTInterpreter new.
	interpreterBlock initializeWithProgram: (RBParser parseExpression:
			 '[ :each | [:point | point + (5 @ 8) ] value: each @ each ] value: 4').
	"stop at the beginning of the embedded block context"
	interpreterBlock
		stepOver;
		stepOver;
		stepInto;
		stepOver;
		stepOver;
		stepOver;
		stepOver;
		stepInto.
	blockContext := interpreterBlock currentContext
]

{ #category : #tests }
DASTContextTests >> testContextInitialization [
	context := DASTContext new.
	self assert: context executedNodes isEmpty
]

{ #category : #tests }
DASTContextTests >> testDASTBlockContextAsContextKeepsSameEquivalentPc [

	| bcContext nextNode nodes |
	interpreterBlock
		stepOver;
		stepOver;
		stepOver.
	bcContext := blockContext asContext.

	"We check that bcContext and its senders have the same receiver and arguments the DASTContext and its senders"
	[ bcContext ] whileNotNil: [ 
		nodes := blockContext nodes copy.
		nextNode := nodes pop.
		[ blockContext methodOrBlock nodeAST firstPcForNode: nextNode ] 
			whileNil: [ nextNode := nodes pop ].

		self
			assert: bcContext pc
			equals:
			(blockContext methodOrBlock nodeAST firstPcForNode: nextNode).

		bcContext := bcContext sender.
		blockContext := blockContext sender ]
]

{ #category : #tests }
DASTContextTests >> testDASTBlockContextAsContextKeepsSameReceiverSenderAndArguments [

	| arguments receiver bcContext bcMethod dastMethod |
	bcContext := blockContext asContext.

	"We check that bcContext and its senders have the same receiver and arguments the DASTContext and its senders"
	[ bcContext ] whileNotNil: [ 
		receiver := blockContext receiver.
		arguments := blockContext arguments.
		bcMethod := bcContext method.
		dastMethod := blockContext methodOrBlock compiledCode.
		self
			assert: bcContext receiver identicalTo: receiver;
			assertCollection: bcContext arguments hasSameElements: arguments;
			assert: bcContext method sourceCode
			equals: blockContext methodOrBlock compiledCode sourceCode.

		bcContext := bcContext sender.
		blockContext := blockContext sender ].

	self assert: blockContext isRoot
]

{ #category : #tests }
DASTContextTests >> testDASTBlockContextAsContextKeepsSameStack [

	| bcContext stack |
	interpreterBlock
		stepOver;
		stepOver;
		stepOver.
	bcContext := blockContext asContext.

	"We check that bcContext and its senders have the same receiver and arguments the DASTContext and its senders"
	[ bcContext ] whileNotNil: [ 
		stack := blockContext stack.

		self
			assert: bcContext stackPtr
			equals: stack size + blockContext variablesDict size.
		1 to: stack size do: [ :each | 
		self assert: stack pop identicalTo: bcContext pop ].

		bcContext := bcContext sender.
		blockContext := blockContext sender ]
]

{ #category : #tests }
DASTContextTests >> testDASTMethodContextAsContextHasSameResult [

	| bcContext process result |
	interpreterMethod
		stepOver;
		stepOver.
	bcContext := methodContext asContext.
	process := Process
		           forContext: bcContext
		           priority: Processor userInterruptPriority.

	result := interpreterMethod evaluate.

	process completeTo: bcContext sender.
	self assert: process suspendedContext top equals: result.

	self shouldnt: [ process resume ] raise: [ Exception ]
]

{ #category : #tests }
DASTContextTests >> testDASTMethodContextAsContextKeepsSameEquivalentPc [

	| bcContext nextNode nodes |
	interpreterMethod
		stepOver;
		stepOver.
	bcContext := methodContext asContext.

	"We check that bcContext and its senders have the same receiver and arguments the DASTContext and its senders"
	[ bcContext ] whileNotNil: [ 
		nodes := methodContext nodes copy.
		nextNode := nodes pop.
		[ methodContext methodOrBlock nodeAST firstPcForNode: nextNode ] 
			whileNil: [ nextNode := nodes pop ].

		self
			assert: bcContext pc
			equals:
			(methodContext methodOrBlock nodeAST firstPcForNode: nextNode).

		bcContext := bcContext sender.
		methodContext := methodContext sender ]
]

{ #category : #tests }
DASTContextTests >> testDASTMethodContextAsContextKeepsSameReceiverSenderAndArguments [

	| arguments receiver bcContext |
	bcContext := methodContext asContext.

	"We check that bcContext and its senders have the same receiver and arguments the DASTContext and its senders"
	[ bcContext ] whileNotNil: [ 
		receiver := methodContext receiver.
		arguments := methodContext arguments.

		self
			assert: bcContext receiver identicalTo: receiver;
			assertCollection: bcContext arguments hasSameElements: arguments;
			assert: bcContext method
			identicalTo: methodContext methodOrBlock compiledCode.

		bcContext := bcContext sender.
		methodContext := methodContext sender ].

	self assert: methodContext isRoot
]

{ #category : #tests }
DASTContextTests >> testDASTMethodContextAsContextKeepsSameStack [

	| bcContext stack |
	interpreterMethod
		stepOver;
		stepOver.
	bcContext := methodContext asContext.

	"We check that bcContext and its senders have the same receiver and arguments the DASTContext and its senders"
	[ bcContext ] whileNotNil: [ 
		stack := methodContext stack.

		self
			assert: bcContext stackPtr
			equals: stack size + methodContext allTemps size.
		1 to: stack size do: [ :each | 
		self assert: stack pop identicalTo: bcContext pop ].

		bcContext := bcContext sender.
		methodContext := methodContext sender ]
]

{ #category : #tests }
DASTContextTests >> testDASTRootContextAsContext [

	| bcContext |
	self assert: rootContext sender isNil.

	bcContext := rootContext asContext.

	self assert: bcContext isNil
]

{ #category : #stack }
DASTContextTests >> testStackPopEmpty [
	| stack |
	stack := DASTStack new.
	self should: [ stack pop ] raise: Exception
]

{ #category : #stack }
DASTContextTests >> testStackPushPop [
	| stack |
	stack := DASTStack new
		push: 3;
		push: 5;
		yourself.
	self assert: stack pop equals: 5.
	self assert: stack pop equals: 3.
]

{ #category : #stack }
DASTContextTests >> testStackPushTop [
	| stack |
	stack := DASTStack new
		push: 3;
		push: 5;
		yourself.
	self assert: stack top equals: 5.
	self assert: stack pop equals: 5.
	self assert: stack pop equals: 3.
	
]

{ #category : #stack }
DASTContextTests >> testStackPushValueLink [
	| stack |
	stack := DASTStack new
		push: (ValueLink value: 4);
		push: (ValueLink value: nil);
		yourself.
	self assert: stack pop value equals: nil.
	self assert: stack pop value equals: 4.
]
