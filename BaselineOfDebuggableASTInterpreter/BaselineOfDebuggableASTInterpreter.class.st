Class {
	#name : #BaselineOfDebuggableASTInterpreter,
	#superclass : #BaselineOf,
	#category : #BaselineOfDebuggableASTInterpreter
}

{ #category : #baselines }
BaselineOfDebuggableASTInterpreter >> baseline: spec [

	<baseline>
	spec for: #common do: [ 

		"Packages"
		spec
			package: 'DebuggableASTInterpreter';
			package: 'DebuggableASTDebugger' with: [ 
				spec requires: #( 'DebuggableASTInterpreter' ) ] ].

	"Groups"
	spec
		group: 'default' with: #( 'Model' );
		group: 'Model' with: #( 'DebuggableASTInterpreter' );
		group: 'Debugger' with: #( 'DebuggableASTDebugger' )
]
