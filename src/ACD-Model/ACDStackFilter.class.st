Class {
	#name : #ACDStackFilter,
	#superclass : #Object,
	#instVars : [
		'context'
	],
	#category : #'ACD-Model'
}

{ #category : #'as yet unclassified' }
ACDStackFilter class >> forContext: aContext [

	^ self new forContext: aContext
]

{ #category : #'accessing actions' }
ACDStackFilter >> extractActiveSubscriptions [

	^ context ifNotNilDo: [:aContext| aContext sender sender sender tempAt: 2]
]

{ #category : #'accessing actions' }
ACDStackFilter >> extractAnnouncement [

	^ context ifNotNilDo: [:aContext| aContext sender sender sender tempAt: 1]
]

{ #category : #'accessing actions' }
ACDStackFilter >> extractExecutingSubscription [
	

	^ context ifNotNilDo: [:aContext||deliveryContext|
		deliveryContext := aContext sender sender sender.
		(deliveryContext tempAt: 2) at:  (deliveryContext tempAt: 4)  ]
]

{ #category : #'accessing actions' }
ACDStackFilter >> extractExecutingSubscriptionIndex [
	

	^ context ifNotNilDo: [:aContext||deliveryContext|
		deliveryContext := aContext sender sender sender.
		deliveryContext tempAt: 4 ]
]

{ #category : #'filtering actions' }
ACDStackFilter >> filterBifrostAdaptations [
	"Filter the stack frames added by Bifrost in order to execute the adaptation."
	
	"If there are no bifrost adaptations do not do any filtering."
	(context isNil or: [context method selector ~= #withArgs:executeMethod:]) ifTrue: [ ^ self ].
	
	(context sender isNil or: [context sender sender isNil]) ifTrue: [ self filterFailed. ^ self ].
	
	"(context method selector = #withArgs:executeMethod: and: ["
		(context sender method selector = #run:with:in: and: [
			context sender sender method selector = #run:with:in: ]) ifTrue: [ context := context sender sender sender. ^ self ].
		
	self filterFailed
]

{ #category : #'filtering actions' }
ACDStackFilter >> filterDeliveryToReceiver [
	"Filter all contexts until the subscription context that triggered the delivery is reached."
	
	"Skip the mesage send used to deliver the announcer."
	context isNil ifTrue: [self filterFailed. ^ self].
	context receiver isMessageSend ifFalse: [ self filterFailed. ^ self ].
	[context receiver isMessageSend ] 
		whileTrue: [context := context sender].
		
	"The message send is triggered by a BlockClosure"
	(context receiver isClosure or: [context isClosureContext] )ifFalse: [ self filterFailed. ^ self ].
	[ context receiver isClosure or: [context isClosureContext ] ]
		whileTrue: [context := context sender].
	
	"If this context represents the method AnnouncementSubscription>>delived: then an announcer is involved."
	(context isNil not and: [context receiver class = AnnouncementSubscription ]) 
		ifTrue: [ ^ context ] ifFalse: [ self filterFailed. ^ self ]
]

{ #category : #private }
ACDStackFilter >> filterFailed [

	context := nil
]

{ #category : #'filtering actions' }
ACDStackFilter >> filterInternalAnnouncerContexts [
	"Filter all contexts until the one that triggered the announcer is found."

	"TODO: fail if we exit announcer contexts"
	[context  isNil not and: [context method selector ~= #announce: ] ] 
		whileTrue: [ context := context sender ]
]

{ #category : #initialization }
ACDStackFilter >> forContext: aContext [

	context := aContext 
]

{ #category : #actions }
ACDStackFilter >> locateAnnouncementDelivery [
	
	^ self filterBifrostAdaptations;
		filterDeliveryToReceiver;
		result
]

{ #category : #actions }
ACDStackFilter >> locateAnnouncementDeliveryLoopContext [

	^ self 
		locateAnnouncementDelivery;
		sender;
		sender;
		sender;
		result
]

{ #category : #actions }
ACDStackFilter >> locateAnnouncerEntryPoint [

	^ self filterBifrostAdaptations;
		filterDeliveryToReceiver;
		filterInternalAnnouncerContexts;
		result
]

{ #category : #accessing }
ACDStackFilter >> result [

	^ context
]

{ #category : #private }
ACDStackFilter >> sender [

	^ context isNil ifFalse: [ context := context sender ]
]
