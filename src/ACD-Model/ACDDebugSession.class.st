Class {
	#name : #ACDDebugSession,
	#superclass : #DebugSession,
	#instVars : [
		'senderContext',
		'announcerModel',
		'receiverContext'
	],
	#category : #'ACD-Model'
}

{ #category : #accessing }
ACDDebugSession class >> stackFilterFor: aContext [ 

	^ ACDContextLocator forContext: aContext 
]

{ #category : #accessing }
ACDDebugSession >> activeSubscriptions [

	^ announcerModel activeSubscriptions
]

{ #category : #accessing }
ACDDebugSession >> announcement [

	^ announcerModel announcement 
]

{ #category : #accessing }
ACDDebugSession >> announcementLoopContext [
	
	^ (self stackFilterFor: receiverContext) locateAnnouncementDelivery
]

{ #category : #accessing }
ACDDebugSession >> announcer [

	^ announcerModel announcer
]

{ #category : #accessing }
ACDDebugSession >> announcerContext [

	^ announcerModel context
]

{ #category : #'predicates creation' }
ACDDebugSession >> createStepPredicateForPredicate: aPredicate [

	^ self createStepPredicateForPredicate: aPredicate fromContext: self announcerContext
]

{ #category : #predicates }
ACDDebugSession >> deliveryStart [ 

	^ self createPredicateForBlock: [ :aContext | 
			aContext receiver isSubscription and: [  
				aContext selector =  #deliver: and: [ 
					aContext closure notNil ] ] ]
]

{ #category : #accessing }
ACDDebugSession >> executingSubscription [

	^ announcerModel executingSubscription 
]

{ #category : #testing }
ACDDebugSession >> hasMoreActiveSubscriptions [

	^ announcerModel hasMoreActiveSubscriptions
]

{ #category : #testing }
ACDDebugSession >> hasSubscriptionExecuted: aSubscription [

	^ announcerModel hasSubscriptionExecuted: aSubscription
]

{ #category : #initialization }
ACDDebugSession >> initializeSenderContext: aSenderContext announcerContext: anAnnouncerContext receiverContext: aReceiverContext [

	senderContext := aSenderContext.
	announcerModel := ACDAnnouncerModel forAnnouncerContext: anAnnouncerContext receiverContext: aReceiverContext.
	receiverContext := aReceiverContext 
]

{ #category : #initialization }
ACDDebugSession >> process: aProcess context: aContext [
	| announcerContext |
	super process: aProcess context: aContext.
	
	announcerContext := (ACDContextLocator forContext: aContext sender) locateAnnouncerEntryPoint.
	self 
		initializeSenderContext: announcerContext sender 
		announcerContext: announcerContext 
		receiverContext: aContext
	

]

{ #category : #accessing }
ACDDebugSession >> receiver [

	^ receiverContext receiver 
]

{ #category : #accessing }
ACDDebugSession >> receiverContext [

	^ receiverContext
]

{ #category : #accessing }
ACDDebugSession >> sender [

	^ senderContext receiver
]

{ #category : #accessing }
ACDDebugSession >> senderContext [

	^ senderContext
]

{ #category : #private }
ACDDebugSession >> stackFilterFor: aContext [ 

	^ self class stackFilterFor: aContext 
]

{ #category : #'debugging actions' }
ACDDebugSession >> stepToNextSubscription [
	"Step over the delivery of the current announcement."
	
	self stepOver: self announcementLoopContext.
	self stepUntil: self deliveryStart.
	(self deliveryStart matches: self interruptedContext) ifTrue: [ 
		self stepUntil: (self subscriptionCompletion).
		self updateReceiver ].
]

{ #category : #'debugging actions' }
ACDDebugSession >> stepUntil: aPredicate [

	^ self stepUntil: aPredicate from: self interruptedContext.
]

{ #category : #predicates }
ACDDebugSession >> subscriptionCompletion [ 
	| aSubscription |
	aSubscription := self interruptedContext receiver.
	^ self createPredicateForBlock: [ :aContext |  
			aContext receiver == aSubscription subscriber and: [
				aContext method selector = aSubscription action selector] ].
]

{ #category : #predicates }
ACDDebugSession >> subscriptionCompletionFor: aSubscription. [
	
	^ self createPredicateForBlock: [ :aContext |  
			aContext receiver == aSubscription subscriber and: [
				aContext method selector = aSubscription action selector] ].
]

{ #category : #updating }
ACDDebugSession >> updateFromReceiverContext: aContext [
	|announcerContext|

	announcerContext := (self stackFilterFor: aContext sender) locateAnnouncerEntryPoint.
	self initializeSenderContext: announcerContext sender announcerContext: announcerContext receiverContext: aContext
]

{ #category : #updating }
ACDDebugSession >> updateReceiver [
	
	^ self updateFromReceiverContext: self interruptedContext
]
