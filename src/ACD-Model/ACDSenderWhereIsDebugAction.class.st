Class {
	#name : #ACDSenderWhereIsDebugAction,
	#superclass : #WhereIsDebugAction,
	#category : #'ACD-Model'
}

{ #category : #registration }
ACDSenderWhereIsDebugAction class >> gtActionFor: aDebugger [
	<gtACDSenderDebuggingAction>
	
	^ (self forDebugger: aDebugger)
			icon: GLMUIThemeExtraIcons glamorousSearch
]

{ #category : #'as yet unclassified' }
ACDSenderWhereIsDebugAction >> executeAction [

	self debugger updateSenderCodeSelection
]

{ #category : #'as yet unclassified' }
ACDSenderWhereIsDebugAction >> id [

	^ #acdSenderWhereIs
]
