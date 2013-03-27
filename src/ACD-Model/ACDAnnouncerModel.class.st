"
ACDAnnouncerModel models an executing announcer and its subscriptions.

Instance Variables:
	context	<BlockClosure | CascadeNode | ContextPart | DebugContext | Debugger | DynamixActivation | Exception | FAMIXInvocation | MessageNode | MessageSend | MooseQueryResult | RBCascadeNode | RBMessageNode | WeakMessageSend>
	announcement	<ProtoObject>
	currentSubscription	<OrderedCollection>
	pendingSubscriptions	<OrderedCollection>
	deliveredSubscriptions	<OrderedCollection>
	idleSubscriptions	<OrderedCollection>
"
Class {
	#name : #ACDAnnouncerModel,
	#superclass : #Object,
	#instVars : [
		'context',
		'receiverContext',
		'announcement',
		'executingSubscription',
		'pendingSubscriptions',
		'executedSubscriptions',
		'idleSubscriptions',
		'allSubscriptions'
	],
	#category : #'ACD-Model'
}

{ #category : #'instance creation' }
ACDAnnouncerModel class >> forAnnouncerContext: announcerContext receiverContext: receiverContext [
	
	^ self new forAnnouncerContext: announcerContext receiverContext: receiverContext
]

{ #category : #'instance creation' }
ACDAnnouncerModel class >> forAnnouncerContext: anAnnouncerContext registryContext: aRegistryContext [ 
	
	^ self new forAnnouncerContext: anAnnouncerContext  registryContext: aRegistryContext
]

{ #category : #'as yet unclassified' }
ACDAnnouncerModel >> allSubscriptions [

	^ allSubscriptions
	
]

{ #category : #accessing }
ACDAnnouncerModel >> announcement [ 

	^ announcement 
]

{ #category : #'as yet unclassified' }
ACDAnnouncerModel >> announcementDeliveryLoopContext [
	
	^ (self stackFilterFor: receiverContext sender) locateAnnouncementDeliveryLoopContext
]

{ #category : #accessing }
ACDAnnouncerModel >> announcer [

	^ self context receiver
]

{ #category : #accessing }
ACDAnnouncerModel >> context [

	^ context 
]

{ #category : #accessing }
ACDAnnouncerModel >> executingSubscription [

	^ executingSubscription
]

{ #category : #initialization }
ACDAnnouncerModel >> forAnnouncerContext: announcerContext receiverContext: aReceiverContext [
	"aContext = A context represeting the delivery of a message send as direct result of an announcement"
	|stackFilter|
	
	self reset.
	
	context := announcerContext.
	"TODO: set announcement when  receiverContext is nil"
	aReceiverContext notNil ifTrue: [
		stackFilter := self stackFilterFor: aReceiverContext sender.
		(stackFilter locateAnnouncementDelivery) isNil ifTrue: [ 
			^ self ]. "aContext was not created as direct result of an announcemnt."
		"self halt."
		announcement := stackFilter extractAnnouncement.
		executingSubscription := stackFilter extractExecutingSubscription. 
		allSubscriptions := stackFilter extractAllSubscriptions.
		
		receiverContext := aReceiverContext ]
	
	
	
	
	
	
]

{ #category : #initialization }
ACDAnnouncerModel >> forAnnouncerContext: anAnnouncerContext registryContext: aRegistryContext [
	"announcerContext = Context representing the method announce: of an announcer."
	"registryContext = The first context representing method SubscriptionRegistry>>deliver:to: created as a result of calling announce: on an announcer."
	
	self reset.
	
	context := anAnnouncerContext.

	announcement := aRegistryContext tempAt: 1.
	allSubscriptions := aRegistryContext tempAt: 2.
		
	
	
	
	
	
]

{ #category : #initialization }
ACDAnnouncerModel >> reset [

	context := nil.
	receiverContext := nil.
	announcement := nil.
	self resetSubscriptions.
	
	
	
	
]

{ #category : #initialization }
ACDAnnouncerModel >> resetSubscriptions [

	executingSubscription := nil.
	pendingSubscriptions := OrderedCollection new.
	executedSubscriptions := OrderedCollection new.
	idleSubscriptions := OrderedCollection new.
	allSubscriptions := OrderedCollection new.
]

{ #category : #private }
ACDAnnouncerModel >> stackFilterFor: aContext [ 

	^ ACDStackFilter forContext: aContext 
]
