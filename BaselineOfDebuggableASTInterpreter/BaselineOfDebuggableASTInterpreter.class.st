Class {
	#name : #BaselineOfDebuggableASTInterpreter,
	#superclass : #BaselineOf,
	#category : #BaselineOfDebuggableASTInterpreter
}

{ #category : #baselines }
BaselineOfDebuggableASTInterpreter >> baseline: spec [

	<baseline>
	spec for: #common do: [ "Dependencies"
		spec
			baseline: 'Espell2'
			with: [ spec repository: 'github://carolahp/Espell2' ].
		spec
			baseline: 'Ghost'
			with: [ spec repository: 'gitlab://gitlab.inria.fr:RMOD/Ghost' ].

		"Packages"
		spec
			package: 'DebuggableASTInterpreter'
			with: [ spec requires: #( 'Espell2' ) ];
			package: 'DebuggableASTDebugger'
			with: [ spec requires: #( 'DebuggableASTInterpreter' ) ];
			package: 'DebuggableASTInterpreterOverlays'
			with: [ spec requires: #( 'DebuggableASTDebugger'
					   'Ghost' ) ] ].

	"Groups"
	spec
		group: 'default' with: #( 'Model' );
		group: 'Model' with: #( 'DebuggableASTInterpreter' );
		group: 'Debugger' with: #( 'DebuggableASTDebugger' );
		group: 'Overlay' with: #( 'DebuggableASTInterpreterOverlays' )
]
