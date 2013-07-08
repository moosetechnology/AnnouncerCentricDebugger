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
		'announcerContext',
		'receiverContext',
		'announcement',
		'executingSubscriptionIndex',
		'activeSubscriptions',
		'idleSubscriptions'
	],
	#category : #'ACD-Model'
}

{ #category : #'instance creation' }
ACDAnnouncerModel class >> forAnnouncerContext: announcerContext receiverContext: receiverContext [
	
	^ self new forAnnouncerContext: announcerContext receiverContext: receiverContext
]

{ #category : #accessing }
ACDAnnouncerModel >> activeSubscriptions [

	^ OrderedCollection new  
		addAll: activeSubscriptions;
		yourself
	
]

{ #category : #accessing }
ACDAnnouncerModel >> allSubscriptions [

	^ OrderedCollection new  
		addAll: idleSubscriptions; 
		addAll: activeSubscriptions;
		yourself
	
]

{ #category : #accessing }
ACDAnnouncerModel >> announcement [ 

	^ announcement 
]

{ #category : #accessing }
ACDAnnouncerModel >> announcementDeliveryLoopContext [
	
	^ (self stackFilterFor: receiverContext sender) locateAnnouncementDeliveryLoopContext
]

{ #category : #accessing }
ACDAnnouncerModel >> announcer [

	^ self context receiver
]

{ #category : #accessing }
ACDAnnouncerModel >> context [

	^ announcerContext 
]

{ #category : #accessing }
ACDAnnouncerModel >> executingSubscription [

	^ activeSubscriptions at: executingSubscriptionIndex 
]

{ #category : #initialization }
ACDAnnouncerModel >> forAnnouncerContext: anAnnouncerContext receiverContext: aReceiverContext [
	"aContext = A context represeting the delivery of a message send as direct result of an announcement"
	|stackFilter|
	
	self reset.
	
	announcerContext := anAnnouncerContext.

	stackFilter := self stackFilterFor: aReceiverContext sender.
	(stackFilter locateAnnouncementDelivery) isNil ifTrue: [ ^ self ]. "aContext was not created as direct result of an announcemnt."
		
	announcement := stackFilter extractAnnouncement.
	executingSubscriptionIndex := stackFilter extractExecutingSubscriptionIndex. 
	activeSubscriptions := Array withAll: stackFilter extractActiveSubscriptions.
		
	receiverContext := aReceiverContext 
	
	
	
	
	
	
]

{ #category : #testing }
ACDAnnouncerModel >> hasMoreActiveSubscriptions [

	^ executingSubscriptionIndex < activeSubscriptions size
]

{ #category : #initialization }
ACDAnnouncerModel >> reset [

	announcerContext := nil.
	receiverContext := nil.
	announcement := nil.
	self resetSubscriptions.
	
	
	
	
]

{ #category : #initialization }
ACDAnnouncerModel >> resetSubscriptions [

	executingSubscriptionIndex := 0.
	activeSubscriptions := Array new.
	idleSubscriptions := Array new.
]

{ #category : #private }
ACDAnnouncerModel >> stackFilterFor: aContext [ 

	^ ACDStackFilter forContext: aContext 
]
