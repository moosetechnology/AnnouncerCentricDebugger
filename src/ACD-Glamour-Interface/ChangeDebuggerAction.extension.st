Extension { #name : #ChangeDebuggerAction }

{ #category : #'*ACD-Glamour-Interface' }
ChangeDebuggerAction classSide >> gtACDChangeDebuggerActionsFor: aDebugger [
	<gtACDReceiverDebuggingAction>
	
	^ self 
		changeDebuggerActionsForContext: aDebugger currentContext 
		excluding: aDebugger
]
