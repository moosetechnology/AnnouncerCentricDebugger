Extension { #name : #RunToHereDebugAction }

{ #category : #'*ACD-Model' }
RunToHereDebugAction classSide >> gtACDReceiverActionTypeFor: aDebugger [
	<gtContextACDReceiverDebuggingAction>

	^ (self forDebugger: aDebugger)
		arguments: [ :action | { action debugger receiverSelectionInterval. action currentContext } ].
]
