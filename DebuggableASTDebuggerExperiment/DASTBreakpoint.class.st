"
1/0.
bp := 
DASTBreakpoint new node: (StDebuggerObjectForTests>>#instVar) ast.
bp install.
StDebuggerObjectForTests new instVar
"
Class {
	#name : 'DASTBreakpoint',
	#superclass : 'BreakDebugPoint',
	#category : 'DebuggableASTDebuggerExperiment',
	#package : 'DebuggableASTDebuggerExperiment'
}
