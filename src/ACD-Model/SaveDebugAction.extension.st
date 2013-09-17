Extension { #name : #SaveDebugAction }

{ #category : #'*ACD-Model' }
SaveDebugAction classSide >> gtACDActionFor: aDebugger [
	<gtACDReceiverDebuggingAction>
	
	^ (self forDebugger: aDebugger)
		icon: GLMUIThemeExtraIcons glamorousAccept
]
