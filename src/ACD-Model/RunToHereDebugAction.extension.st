Extension { #name : #RunToHereDebugAction }

{ #category : #'*ACD-Model' }
RunToHereDebugAction classSide >> gtACDReceiverActionType [
	<gtContextACDReceiverDebuggingAction>

	^ self new
		arguments: [ :action | { action debugger receiverSelectionInterval. action currentContext } ].
]
