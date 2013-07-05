Class {
	#name : #ACDebugSession,
	#superclass : #DebugSession,
	#instVars : [
		'senderContext',
		'announcerModel',
		'receiverContext'
	],
	#category : #'ACD-Model'
}

{ #category : #accessing }
ACDebugSession class >> stackFilterFor: aContext [ 

	^ ACDStackFilter forContext: aContext 
]

{ #category : #accessing }
ACDebugSession >> allSubscriptions [

	^ announcerModel allSubscriptions
]

{ #category : #accessing }
ACDebugSession >> announcement [

	^ announcerModel announcement 
]

{ #category : #accessing }
ACDebugSession >> announcer [

	^ announcerModel announcer
]

{ #category : #accessing }
ACDebugSession >> announcerContext [

	^ announcerModel context
]

{ #category : #accessing }
ACDebugSession >> executingSubscription [

	^ announcerModel executingSubscription 
]

{ #category : #testing }
ACDebugSession >> hasMoreActiveSubscriptions [

	^ announcerModel hasMoreActiveSubscriptions
]

{ #category : #initialization }
ACDebugSession >> initializeSenderContext: aSenderContext announcerContext: anAnnouncerContext receiverContext: aReceiverContext [

	senderContext := aSenderContext.
	announcerModel := ACDAnnouncerModel forAnnouncerContext: anAnnouncerContext receiverContext: aReceiverContext.
	receiverContext := aReceiverContext 
]

{ #category : #accessing }
ACDebugSession >> receiver [

	^ receiverContext receiver 
]

{ #category : #accessing }
ACDebugSession >> receiverContext [

	^ receiverContext
]

{ #category : #accessing }
ACDebugSession >> sender [

	^ senderContext receiver
]

{ #category : #accessing }
ACDebugSession >> senderContext [

	^ senderContext
]

{ #category : #private }
ACDebugSession >> stackFilterFor: aContext [ 

	^ self class stackFilterFor: aContext 
]

{ #category : #initialization }
ACDebugSession >> stepThroughRegistryDeliveryContextFor: anAnnouncerContext [

	self stepInto: anAnnouncerContext.
	[self context receiver class == SubscriptionRegistry 
		and: [self context method selector = #deliver:to: ]] whileFalse: [self stepInto].
]

{ #category : #'as yet unclassified' }
ACDebugSession >> stepToNextSubscription [
	| subscription|
	
	"Step over the delivery of the current announcement."
	self stepOver: announcerModel announcementDeliveryLoopContext.
	
	"If there was a halt, do not perform any more actions."
	(self context selector = #halt) ifTrue: [ "Update the debugger" ^ self ].
	
	"Locate the context in which the subscriptin delivers it's announcer"
	self stepIntoWhileTrue: [ (self context selector ~=  #deliver: or: [self context closure isNil]) and: [ 
		self context selector ~= #deliver:to: ] ]. 

	"If there are no more subscriptions do nothing. Normally this should not happen."
	(self context selector = #deliver:to:) ifTrue: [ ^ self ].

	"For now only message sends are handled"
	"Go through the stack until the message send is executed."
	subscription := self context receiver.
	self stepIntoWhileFalse: [self context receiver == subscription subscriber and: [
		self context method selector = subscription action selector]].

	self updateFromReceiverContext: self context
	
]

{ #category : #initialization }
ACDebugSession >> updateFromReceiverContext: aContext [
	|announcerContext|

	announcerContext := (self stackFilterFor: aContext sender) locateAnnouncerEntryPoint.
	self initializeSenderContext: announcerContext sender announcerContext: announcerContext receiverContext: aContext
]

{ #category : #initialization }
ACDebugSession >> updateFromSenderContext: aContext [

	self initializeSenderContext: aContext announcerContext: announcerModel context receiverContext: receiverContext
]
