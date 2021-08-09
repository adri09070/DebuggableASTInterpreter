Class {
	#name : #DASTEvaluatorWithMarking,
	#superclass : #DASTEvaluator,
	#category : #'DebuggableASTInterpreterBootstrap-Espell'
}

{ #category : #mark }
DASTEvaluatorWithMarking >> markMethodAsAccessed: method [
	" Mark the method as accessed in the ring model for deciding wether or not install it later in the kernel"

	| class result |
	class := method methodClass.
	result := class.
	(class == BlockClosure )
		ifTrue: [ result := self systemDefinition classBlockClosure ].
	(class == DASTContext or: [class == DASTMethodContext])
		ifTrue: [ result := self systemDefinition classContext ].
	(class == Object or: class == ProtoObject)
		ifTrue: [ result := self systemDefinition classProtoObject ].
	result markMethodAsAccessed: method
]

{ #category : #lookup }
DASTEvaluatorWithMarking >> pvtLookupSelector: aByteString startInClass: aClass [
	| class method |
	class := aClass.
	"We perform the lookup"
	method := class lookupSelectorAndMarkTraversedClasses: aByteString.
	method ifNotNil: [
		"we are not marking blockClosure methods in the metamodel, nor adding them :(. 
		Pending!"
		^ method ].
	"If the method was not found and the receiver is aDASTBlock, 
	we must force the lookup to go in the class Block in the ring model"
	class == DASTBlock
		ifTrue: [ class := self systemDefinition classBlockClosure ].
	class == DASTMethodContext
		ifTrue: [ class := self systemDefinition classContext ].
	method := class lookupSelectorAndMarkTraversedClasses: aByteString.
	"If the method was not found it will be nil"
	^ method
]
