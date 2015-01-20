Extension { #name : #GTSaveDebugAction }

{ #category : #'*ACD-Glamour-Interface' }
GTSaveDebugAction class >> gtReceiverDebuggingActionFor: aDebugger [
	"<gtContextReceiverDebuggingAction>"
	
		^ (self gtActionFor: aDebugger)
			codePresentationSelector: #receiverCodePresentation
]
