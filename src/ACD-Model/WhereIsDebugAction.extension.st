Extension { #name : #WhereIsDebugAction }

{ #category : #'*ACD-Model' }
WhereIsDebugAction class >> gtACDReceiverActionFor: aDebugger [
	<gtACDReceiverDebuggingAction>
	
	^ (self forDebugger: aDebugger)
		action: #updateReceiverCodeSelection
]

{ #category : #'*ACD-Model' }
WhereIsDebugAction class >> gtACDSenderActionFor: aDebugger [
	<gtACDSenderDebuggingAction>
	
	^ (self forDebugger: aDebugger)
		action: #updateSenderCodeSelection
]
