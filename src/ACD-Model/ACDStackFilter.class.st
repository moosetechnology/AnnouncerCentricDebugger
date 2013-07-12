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

	^ context ifNotNilDo: [:aContext| aContext tempAt: 1]
]

{ #category : #'accessing actions' }
ACDStackFilter >> extractExecutingSubscription [
	
	^ context ifNotNilDo: [:aContext|
		(aContext tempAt: 2) at: (aContext tempAt: 4)  ]
]

{ #category : #'accessing actions' }
ACDStackFilter >> extractExecutingSubscriptionIndex [

	^ context ifNotNilDo: [:aContext| aContext tempAt: 4 ]
]

{ #category : #private }
ACDStackFilter >> filterFailed [

	context := nil
]

{ #category : #private }
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
		skipUntilSubscriptionDeliveryContext;
		result
]

{ #category : #actions }
ACDStackFilter >> locateAnnouncerEntryPoint [
	"Locate the initial context that triggered the delivery of
	a subscription. The initial context is the first that send 
	the message announce:"

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

{ #category : #'filtering actions' }
ACDStackFilter >> skipAllInternalAnnouncerContexts [
	"Filter all contexts until the one that triggered the announcer is found."
	
	self findContextSuchThat: [ :ctxt | 
		(ctxt methodSelector = #announce:) and: [ 
			ctxt methodClass = Announcer ] ]
]

{ #category : #'filtering actions' }
ACDStackFilter >> skipAnnounceContexts [
	
	self findContextSuchThat: [ :ctxt | 
		(ctxt methodSelector ~= #announce:) ]
]

{ #category : #'filtering actions' }
ACDStackFilter >> skipUntilSubscriptionDeliveryContext [

	self findContextSuchThat: [ :aContext | 
		aContext receiver class = SubscriptionRegistry and: [  
			aContext selector =  #deliver:to:startingAt: and: [ 
				aContext closure isNil ] ] ]
]
