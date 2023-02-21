Class {
	#name : #ClyAddDASTBreakpointCommand,
	#superclass : #ClyAddStaticBreakpointCommand,
	#category : #DebuggableASTDebuggerExperiment
}

{ #category : #testing }
ClyAddDASTBreakpointCommand class >> canBeExecutedInContext: aBrowserContext [

	^ (super canBeExecutedInContext: aBrowserContext) and: [
		  aBrowserContext isSelectedItemHasBreakpoint not ]
]

{ #category : #activation }
ClyAddDASTBreakpointCommand class >> contextMenuOrder [
	<classAnnotationDependency>
	^1
]

{ #category : #testing }
ClyAddDASTBreakpointCommand class >> isAbstract [
	^self = ClyAddBreakpointCommand
]

{ #category : #accessing }
ClyAddDASTBreakpointCommand >> defaultMenuItemName [
	^'DAST breakpoint'
]

{ #category : #execution }
ClyAddDASTBreakpointCommand >> execute [

	| breakpoint |
	breakpoint := DASTBreakpoint new node: sourceNode.
	breakpoint install
]
