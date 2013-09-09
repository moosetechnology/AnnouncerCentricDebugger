Class {
	#name : #ACDSenderCalleeAction,
	#superclass : #DebugAction,
	#category : #'ACD-Model'
}

{ #category : #registration }
ACDSenderCalleeAction class >> gtACDSenderActionFor: aDebugger [
	<gtACDSenderDebuggingAction>
]

{ #category : #'as yet unclassified' }
ACDSenderCalleeAction >> defaultIcon [

	^ GLMUIThemeExtraIcons glamorousRight
]

{ #category : #'as yet unclassified' }
ACDSenderCalleeAction >> defaultLabel [

	^ 'Next Context'
]

{ #category : #'as yet unclassified' }
ACDSenderCalleeAction >> executeAction [

	self session updateSenderFrom: (self session process calleeOf:  self session senderContext) 
]
