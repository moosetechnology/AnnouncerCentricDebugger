Extension { #name : #WhereIsDebugAction }

{ #category : #'*ACD-Glamour-Interface' }
WhereIsDebugAction class >> gtACDReceiverActionFor: aDebugger [
	<gtACDReceiverDebuggingAction>
	
	^ self new
		action: #updateReceiverCodeSelection
]

{ #category : #'*ACD-Glamour-Interface' }
WhereIsDebugAction class >> gtACDSenderActionFor: aDebugger [
	<gtACDSenderDebuggingAction>
	
	^ self new
		action: #updateSenderCodeSelection
]
