Class {
	#name : #DASTPostOrderTreeVisitor,
	#superclass : #Object,
	#instVars : [
		'stack'
	],
	#category : #'DebuggableASTInterpreter-NodeArrangement'
}

{ #category : #api }
DASTPostOrderTreeVisitor >> flattenedNodesFrom: aRBNode [ 
	(aRBNode methodNode body addReturn; yourself) acceptVisitor: self.
	^ self stack.
	
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> initialize [ 

	super initialize.
	stack := DASTStack new
]

{ #category : #accessing }
DASTPostOrderTreeVisitor >> stack [
	^ stack
]

{ #category : #accessing }
DASTPostOrderTreeVisitor >> top [
	
	^ stack top
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitArgumentNode: aRBArgumentNode [ 
	^ stack push: aRBArgumentNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitArgumentVariableNode: aRBVariableNode [ 

	stack push: aRBVariableNode 
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitArrayNode: aRBArrayNode [ 
	stack push: aRBArrayNode.
	aRBArrayNode children reverse do: [ :e | e acceptVisitor: self ].	
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitAssignmentNode: aRBAssignmentNode [ 

	stack push: aRBAssignmentNode.
	aRBAssignmentNode value acceptVisitor: self
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitBlockNode: aRBBlockNode [ 
	stack push: aRBBlockNode 
]

{ #category : #accessing }
DASTPostOrderTreeVisitor >> visitCascadeNode: aRBCascadeNode [ 
	stack push: aRBCascadeNode.
	aRBCascadeNode children reverse do: [ :e | e acceptVisitor: self ]
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitClassVariableNode: aNode [

	^ self visitLiteralVariableNode: aNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitGlobalNode: aRBGlobalNode [ 
	stack push: aRBGlobalNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitGlobalVariableNode: aNode [

	^ self visitLiteralVariableNode: aNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitInstanceVariableNode: aRBInstanceVariableNode [ 
	stack push: aRBInstanceVariableNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitLiteralArrayNode: aRBLiteralArrayNode [ 
	stack push: aRBLiteralArrayNode.
	aRBLiteralArrayNode contents do: [ :e | e acceptVisitor: self ].	
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitLiteralNode: aRBLiteralValueNode [ 

	stack push: aRBLiteralValueNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitLiteralValueNode: aRBLiteralValueNode [ 

	^ self visitLiteralNode: aRBLiteralValueNode 
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitLiteralVariableNode: aNode [
	"to be backward compatible, we visit for Gloabls here (there used to be no difference)"

	^ self visitGlobalNode: aNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitLocalVariableNode: aNode [

	"call visitTemporaryNode: for backward compatibility"

	^ self visitTemporaryNode: aNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitMessageNode: aRBMessageNode [ 

	stack push: aRBMessageNode.
	aRBMessageNode arguments reverse do: [ :e | e acceptVisitor: self ].
	(aRBMessageNode isCascaded not or: [aRBMessageNode isFirstCascaded]) ifTrue: [ aRBMessageNode receiver acceptVisitor: self ].
	
	
	

]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitMethodNode: aRBMethodNode [ 
	
	stack push: aRBMethodNode.
	aRBMethodNode body acceptVisitor: self.
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitReturnNode: aRBReturnNode [ 
	
	stack push: aRBReturnNode.

	aRBReturnNode value acceptVisitor: self
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitSelfNode: aRBSelfNode [ 
	stack push: aRBSelfNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitSequenceNode: aRBSequenceNode [ 

	stack push: aRBSequenceNode.
	aRBSequenceNode children reverse do: [ :e | e acceptVisitor: self ].	
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitSuperNode: aRBSuperNode [ 
	^ stack push: aRBSuperNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitTemporaryNode: aRBTemporaryNode [ 
	stack push: aRBTemporaryNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitTemporaryVariableNode: aRBVariableNode [ 

	stack push: aRBVariableNode 
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitThisContextNode: aRBThisContextNode [ 
	stack push: aRBThisContextNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitVariableNode: aRBVariableNode [ 
	
	stack push: aRBVariableNode 
]
