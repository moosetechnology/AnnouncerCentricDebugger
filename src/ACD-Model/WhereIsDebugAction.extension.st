Extension { #name : #WhereIsDebugAction }

{ #category : #'*ACD-Model' }
WhereIsDebugAction class >> gtACDReceiverActionFor: aDebugger [
	<gtACDReceiverDebuggingAction>
	
	^ self new
		action: #updateReceiverCodeSelection
]

{ #category : #'*ACD-Model' }
WhereIsDebugAction class >> gtACDSenderActionFor: aDebugger [
	<gtACDSenderDebuggingAction>
	
	^ self new
		action: #updateSenderCodeSelection
]
