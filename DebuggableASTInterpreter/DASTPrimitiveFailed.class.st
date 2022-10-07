Class {
	#name : #DASTPrimitiveFailed,
	#superclass : #Error,
	#instVars : [
		'primitiveNumber',
		'receiver',
		'errorCode'
	],
	#category : #'DebuggableASTInterpreter-Exceptions'
}

{ #category : #instantiation }
DASTPrimitiveFailed class >> primitiveNumber: anInteger receiver: anObject [ 
	^ self new
		primitiveNumber: anInteger; 
		receiver: anObject; 
		yourself
]

{ #category : #signaling }
DASTPrimitiveFailed class >> primitiveNumber: anInteger receiver: anObject errorCode: ec [

	^ (self primitiveNumber: anInteger receiver: anObject)
		  errorCode: ec;
		  yourself
]

{ #category : #signaling }
DASTPrimitiveFailed class >> signalWithPrimitive: anInteger receiver: anObject [
	^(self primitiveNumber: anInteger receiver: anObject) signal
]

{ #category : #signalling }
DASTPrimitiveFailed class >> signalWithPrimitive: anInteger receiver: anObject errorCode: ec [

	^ (self primitiveNumber: anInteger receiver: anObject errorCode: ec)
		  signal
]

{ #category : #accessing }
DASTPrimitiveFailed >> errorCode [

	^ errorCode
]

{ #category : #accessing }
DASTPrimitiveFailed >> errorCode: anObject [

	errorCode := anObject
]

{ #category : #testing }
DASTPrimitiveFailed >> isResumable [

	^ true
]

{ #category : #accessing }
DASTPrimitiveFailed >> primitiveNumber: anInteger [ 
	primitiveNumber := anInteger
]

{ #category : #accessing }
DASTPrimitiveFailed >> receiver: anObject [ 
	receiver := anObject
]
