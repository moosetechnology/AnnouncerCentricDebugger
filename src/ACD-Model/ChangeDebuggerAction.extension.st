Extension { #name : #ChangeDebuggerAction }

{ #category : #'*ACD-Model' }
ChangeDebuggerAction classSide >> gtACDChangeDebuggerActionsFor: aDebugger [
	<gtACDReceiverDebuggingAction>
	
	^ self 
		changeDebuggerActionsForContext: aDebugger interruptedContext 
		excluding: aDebugger
]
