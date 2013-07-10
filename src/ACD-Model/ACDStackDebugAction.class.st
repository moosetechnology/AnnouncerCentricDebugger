Class {
	#name : #ACDStackDebugAction,
	#superclass : #StackDebugAction,
	#category : #'ACD-Model'
}

{ #category : #'as yet unclassified' }
ACDStackDebugAction class >> gtStackActions [
	<gtACDReceiverDebuggingAction>
	
	^ super gtStackActions
]

{ #category : #testing }
ACDStackDebugAction >> appliesToContext: aContext [

	^ (self session receiverContext = self session context and: [
		self session context willReturn]) not
]
