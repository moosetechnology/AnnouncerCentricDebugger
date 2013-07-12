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

	^ context ifNotNilDo: [:aContext| aContext tempAt: 2]
]

{ #category : #'accessing actions' }
ACDStackFilter >> extractAnnouncement [

	^ context ifNotNilDo: [:aContext| aContext  tempAt: 1]
]

{ #category : #'accessing actions' }
ACDStackFilter >> extractExecutingSubscription [
	

	^ context ifNotNilDo: [:aContext|
		(aContext tempAt: 2) at: (aContext tempAt: 4)  ]
]

{ #category : #'accessing actions' }
ACDStackFilter >> extractExecutingSubscriptionIndex [
	

	^ context ifNotNilDo: [:aContext|
		aContext tempAt: 4 ]
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
	
	"If this context represents the method delived: froma subscription then an announcer is involved."
	(context isNil not and: [context receiver class = AnnouncementSubscription or: [ context receiver class = WeakAnnouncementSubscription ] ]) 
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
		whileTrue: [ context := context sender ].
		
	context isNil ifTrue: [ self filterFailed. ^ self ].
	
	[ context sender notNil and: [ context sender selector = #announce: ] ] 
		whileTrue: [ context := context sender ]
]

{ #category : #actions }
ACDStackFilter >> findContextSuchThat: testBlock [

	^ context 
		ifNil: [ nil ] 
		ifNotNil: [ context := context findContextSuchThat: testBlock ]
	
]

{ #category : #initialization }
ACDStackFilter >> forContext: aContext [

	context := aContext 
]

{ #category : #actions }
ACDStackFilter >> locateAnnouncementDelivery [
	"Locate the context responsible with initiating the delivery of a subscription.
	From this context the active subscriptions and the current executing subscription,
	should be extracted."
	
	^ self 
		skipUntilSubscriptionDeliveryContexts;
		result
]

{ #category : #actions }
ACDStackFilter >> locateAnnouncerEntryPoint [

	^ self 
		skipAllInternalAnnouncerContexts;
		skipAnnounceContexts;
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

{ #category : #actions }
ACDStackFilter >> skipAllInternalAnnouncerContexts [
	"Filter all contexts until the one that triggered the announcer is found."
	
	self findContextSuchThat: [ :ctxt | 
		(ctxt methodSelector = #announce:) and: [ 
			ctxt methodClass = Announcer ] ]
]

{ #category : #actions }
ACDStackFilter >> skipAnnounceContexts [
	
	self findContextSuchThat: [ :ctxt | 
		(ctxt methodSelector ~= #announce:) ]
]

{ #category : #actions }
ACDStackFilter >> skipUntilSubscriptionDeliveryContexts [

	self findContextSuchThat: [ :aContext | 
		aContext receiver class = SubscriptionRegistry and: [  
			aContext selector =  #deliver:to:startingAt: and: [ 
				aContext closure isNil ] ] ]
]
