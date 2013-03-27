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
ACDebugSession >> hasReceiver [
]

{ #category : #initialization }
ACDebugSession >> initializeSenderContext: aSenderContext [ 
	| ctx |
	
	self stepInto: aSenderContext.
	self stepInto.
	self initializeSenderContext: aSenderContext announcerContext: self context
]

{ #category : #initialization }
ACDebugSession >> initializeSenderContext: aSenderContext announcerContext: anAnnouncerContext [ 
	| registryContext |

	senderContext := aSenderContext.
	self stepThroughRegistryDeliveryContextFor: anAnnouncerContext. 
	registryContext := self context.
	announcerModel := ACDAnnouncerModel forAnnouncerContext: anAnnouncerContext registryContext: registryContext
]

{ #category : #initialization }
ACDebugSession >> initializeSenderContext: aSenderContext announcerContext: anAnnouncerContext receiverContext: aReceiverContext [

	senderContext := aSenderContext.
	announcerModel := ACDAnnouncerModel forAnnouncerContext: anAnnouncerContext receiverContext: aReceiverContext.
	receiverContext := aReceiverContext 
]

{ #category : #testing }
ACDebugSession >> isSubscriptionExecuting [

	^ announcerModel executingSubscription notNil 
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
	|ctx subscription|
	
	
	self stepOver: announcerModel announcementDeliveryLoopContext.	"Step over the delivery of the current announcement. TODO: take exceptions into account."
	[ self context method selector ~=  #deliver: or: [self context closure isNil] ] whileTrue: [ self stepInto ]. "locate the context in which the subscripton delivers it's announcer"



	"For now only message sends are handled"
	"Go through the stack until the message send is executed."
	"Must take into account unhandled exceptions"
	"GTDebugger debugCurrentProcess ."
	subscription := self context receiver.
	[self context receiver == subscription subscriber and: [
		self context method selector  = subscription action selector]] whileFalse: [ self stepInto ].

	self updateFromReceiverContext: self context
	
]

{ #category : #initialization }
ACDebugSession >> updateFromReceiverContext: aContext [
	|announcerContext|

	announcerContext := (self stackFilterFor: aContext sender) locateAnnouncerEntryPoint.
	self initializeSenderContext: announcerContext sender announcerContext: announcerContext receiverContext: aContext
]
