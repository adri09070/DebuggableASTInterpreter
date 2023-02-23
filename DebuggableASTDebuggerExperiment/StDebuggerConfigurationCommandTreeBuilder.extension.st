Extension { #name : #StDebuggerConfigurationCommandTreeBuilder }

{ #category : #'*DebuggableASTDebuggerExperiment' }
StDebuggerConfigurationCommandTreeBuilder >> dastConfigurationCommandsClasses [

	^ { StSwitchToDASTCommand }
]

{ #category : #'*DebuggableASTDebuggerExperiment' }
StDebuggerConfigurationCommandTreeBuilder >> dastConfigurationCommandsGroup [

	| group |
	group := (CmCommandGroup named: self dastConfigurationGroupName)
		         asSpecGroup.
	group beDisplayedAsSubMenu.
	group description: self dastConfigurationGroupDescription.
	self dastConfigurationCommandsClasses do: [ :c |
		group register:
			(self buildSpecCommand: c forContext: stDebuggerInstance) ].
	^ group
]

{ #category : #'*DebuggableASTDebuggerExperiment' }
StDebuggerConfigurationCommandTreeBuilder >> dastConfigurationGroupDescription [

	^ 'Configuration commands to perform actions with DAST interpreter'
]

{ #category : #'*DebuggableASTDebuggerExperiment' }
StDebuggerConfigurationCommandTreeBuilder >> dastConfigurationGroupName [

	^ 'DAST configuration'
]
