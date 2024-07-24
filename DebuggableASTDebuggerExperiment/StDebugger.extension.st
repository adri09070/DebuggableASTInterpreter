Extension { #name : 'StDebugger' }

{ #category : '*DebuggableASTDebuggerExperiment' }
StDebugger class >> buildDASTCommandsGroupWith: stDebuggerInstance forRoot: aRootGroup [

	<extensionCommands>
	| configGroup dastConfigGroup |
	configGroup := aRootGroup
	               / StDebuggerConfigurationCommandTreeBuilder groupName.
	dastConfigGroup := StDebuggerConfigurationCommandTreeBuilder new
		                   dastConfigurationCommandsGroup.
	configGroup register: dastConfigGroup
]

{ #category : '*DebuggableASTDebuggerExperiment' }
StDebugger >> programmaticallyClose [

	programmaticallyClosed := true.
	self withWindowDo: #close
]
