Class {
	#name : #ACDStackDebugAction,
	#superclass : #StackDebugAction,
	#category : #'ACD-Glamour-Interface'
}

{ #category : #'as yet unclassified' }
ACDStackDebugAction class >> gtStackActions [
	<gtACDReceiverDebuggingAction>
	
	^ super gtStackActions
]

{ #category : #'as yet unclassified' }
ACDStackDebugAction >> appliesToContext: aContext [

	^ (self session receiverContext = self session context and: [
		self session context willReturn]) not
]
