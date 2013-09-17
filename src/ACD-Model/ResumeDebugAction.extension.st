Extension { #name : #ResumeDebugAction }

{ #category : #'*ACD-Model' }
ResumeDebugAction class >> gtACDActionFor: aDebugger [
	<gtACDReceiverDebuggingAction>
	
	^ (self forDebugger: aDebugger)
		icon: GLMUIThemeExtraIcons glamorousPlay
]
