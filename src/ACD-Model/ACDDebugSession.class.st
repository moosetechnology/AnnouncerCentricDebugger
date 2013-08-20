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
ACDDebugSession >> allSubscriptions [

	^ announcerModel allSubscriptions
]

{ #category : #accessing }
ACDDebugSession >> announcement [

	^ announcerModel announcement 
]

{ #category : #accessing }
ACDDebugSession >> announcer [

	^ announcerModel announcer
]

{ #category : #accessing }
ACDDebugSession >> announcerContext [

	^ announcerModel context
]

{ #category : #'as yet unclassified' }
ACDDebugSession >> createStepPredicateForPredicate: aPredicate [

	^ self createStepPredicateForPredicate: aPredicate fromContext: self announcerContext
]

{ #category : #predicates }
ACDDebugSession >> deliveryCompletionPredicateForSubscription: aSubscription. [
	
	^ self createPredicateForBlock: [ :aContext |  
			aContext receiver == aSubscription subscriber and: [
				aContext method selector = aSubscription action selector] ].
]

{ #category : #predicates }
ACDDebugSession >> deliveryInitializationPredicate [ 

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
	self stepOver: announcerModel announcementDeliveryLoopContext.

	self newStepUntil: self deliveryInitializationPredicate from: self interruptedContext.
	
	(self deliveryInitializationPredicate matches: self interruptedContext) ifTrue: [ 
		self 
			newStepUntil: (self deliveryCompletionPredicateForSubscription: self interruptedContext receiver) 
			from: self interruptedContext.
		
		self updateFromReceiverContext: self interruptedContext ].
]

{ #category : #updating }
ACDDebugSession >> updateFromReceiverContext: aContext [
	|announcerContext|

	announcerContext := (self stackFilterFor: aContext sender) locateAnnouncerEntryPoint.
	self initializeSenderContext: announcerContext sender announcerContext: announcerContext receiverContext: aContext
]
