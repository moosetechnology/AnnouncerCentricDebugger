Class {
	#name : #ACDStepToSubscriptionDebugAction,
	#superclass : #DebugAction,
	#instVars : [
		'targetSubscription'
	],
	#category : #'ACD-Model'
}

{ #category : #'as yet unclassified' }
ACDStepToSubscriptionDebugAction class >> acdActionTypeForDebugger: aDebugger [
	<gtContextACDSubscriptionDebuggingAction>
	
	^ (self forDebugger: aDebugger)
		targetSubscription: aDebugger selectedSubscription
		
]

{ #category : #'as yet unclassified' }
ACDStepToSubscriptionDebugAction >> appliesToContext: aContext [

	^ (self session hasSubscriptionExecuted: targetSubscription) not
]

{ #category : #'as yet unclassified' }
ACDStepToSubscriptionDebugAction >> defaultLabel [

	^ 'Step to subscription'
]

{ #category : #'as yet unclassified' }
ACDStepToSubscriptionDebugAction >> deliveryStart [ 

	^ self session createPredicateForBlock: [ :aContext | 
			aContext receiver == targetSubscription and: [ 
					aContext selector =  #deliver: and: [ 
						aContext closure notNil ] ] ] 
]

{ #category : #'as yet unclassified' }
ACDStepToSubscriptionDebugAction >> executeAction [ 

	self session stepOver: self session announcementLoopContext.
	self session stepUntil: self deliveryStart.
	(self deliveryStart matches: self interruptedContext) 
		ifTrue: [ 
			self session stepUntil: (self session subscriptionDelivery).
			self session updateReceiver ]
]

{ #category : #'as yet unclassified' }
ACDStepToSubscriptionDebugAction >> targetSubscription: aSubscription [

	targetSubscription := aSubscription
]
