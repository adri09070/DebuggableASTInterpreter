Class {
	#name : 'ClyAddDASTBreakpointCommand',
	#superclass : 'ClyAddBreakPointCommand',
	#category : 'DebuggableASTDebuggerExperiment',
	#package : 'DebuggableASTDebuggerExperiment'
}

{ #category : 'activation' }
ClyAddDASTBreakpointCommand class >> contextMenuOrder [
	"activation"

	<classAnnotationDependency>
	^ 1
]

{ #category : 'accessing' }
ClyAddDASTBreakpointCommand >> defaultMenuItemName [

	^ 'DAST breakpoint'
]

{ #category : 'execution' }
ClyAddDASTBreakpointCommand >> execute [

	DebugPointManager installNew: DASTBreakpoint on: sourceNode
]
