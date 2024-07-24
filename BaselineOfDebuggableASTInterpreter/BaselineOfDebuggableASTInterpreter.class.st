Class {
	#name : 'BaselineOfDebuggableASTInterpreter',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfDebuggableASTInterpreter',
	#package : 'BaselineOfDebuggableASTInterpreter'
}

{ #category : 'baselines' }
BaselineOfDebuggableASTInterpreter >> baseline: spec [

	<baseline>
	spec for: #common do: [ 

		"Packages"
		spec
			package: 'DebuggableASTInterpreter';
			package: 'DebuggableASTDebugger' with: [ 
				spec requires: #( 'DebuggableASTInterpreter' ) ] ].
		spec package: 'DebuggableASTDebuggerExperiment' with: [ spec requires: #( 'DebuggableASTDebugger' ) ].

	"Groups"
	spec
		group: 'default' with: #( 'Model' );
		group: 'Model' with: #( 'DebuggableASTInterpreter' );
		group: 'Debugger' with: #( 'DebuggableASTDebugger' );
		group: 'DebuggerXP' with: #( 'DebuggableASTDebuggerExperiment' )
]
