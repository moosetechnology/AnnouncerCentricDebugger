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

{ #category : #predicates }
ACDebugSession >> deliveryCompletionPredicateForSubscription: aSubscription. [
	
	^ ContextPredicate new 
			baseContext: self announcerContext;
			action: [ :aContext |  
				aContext receiver == aSubscription subscriber and: [
					aContext method selector = aSubscription action selector] ].
]

{ #category : #predicates }
ACDebugSession >> deliveryInitializationPredicate [ 

	^ ContextPredicate new 
			baseContext: self announcerContext;
			action: [ :aContext | 
				aContext receiver isSubscription and: [  
					aContext selector =  #deliver: and: [ 
						aContext closure notNil ] ] ]
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

{ #category : #'debugging actions' }
ACDebugSession >> stepToNextSubscription [
	| deliveryInitializationPredicate deliveryCompletionPredicate |
	
	"Step over the delivery of the current announcement."
	self stepOver: announcerModel announcementDeliveryLoopContext.
	
	deliveryInitializationPredicate := self deliveryInitializationPredicate.
	self stepUntil: deliveryInitializationPredicate from: self context.
	
	deliveryInitializationPredicate hasMatched ifTrue: [ 
		deliveryCompletionPredicate := self deliveryCompletionPredicateForSubscription: self context receiver.
		self stepUntil: deliveryCompletionPredicate.
		
		self updateFromReceiverContext: self context ].
]

{ #category : #updating }
ACDebugSession >> updateFromReceiverContext: aContext [
	|announcerContext|

	announcerContext := (self stackFilterFor: aContext sender) locateAnnouncerEntryPoint.
	self initializeSenderContext: announcerContext sender announcerContext: announcerContext receiverContext: aContext
]
