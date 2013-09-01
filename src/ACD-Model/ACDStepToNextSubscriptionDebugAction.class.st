Class {
	#name : #ACDStepToNextSubscriptionDebugAction,
	#superclass : #DebugAction,
	#category : #'ACD-Model'
}

{ #category : #registration }
ACDStepToNextSubscriptionDebugAction class >> acdActionType [
	<gtACDSubscriptionDebuggingAction>
]

{ #category : #testing }
ACDStepToNextSubscriptionDebugAction >> appliesToContext: aContext [

	^ self session hasMoreActiveSubscriptions
]

{ #category : #predicates }
ACDStepToNextSubscriptionDebugAction >> deliveryStart [ 

	^ self session createPredicateForBlock: [ :aContext | 
			aContext receiver isSubscription and: [  
				aContext selector =  #deliver: and: [ 
					aContext closure notNil ] ] ]
]

{ #category : #actions }
ACDStepToNextSubscriptionDebugAction >> executeAction [ 
	"Step over the delivery of the current announcement."
	
	self session stepOver: self session announcementLoopContext.
	self session stepUntil: self deliveryStart.
	(self deliveryStart matches: self interruptedContext) ifTrue: [ 
		self session stepUntil: (self session subscriptionDelivery).
		self session updateReceiver ]
]

{ #category : #initialization }
ACDStepToNextSubscriptionDebugAction >> initialize [

	self label: 'Next subscription'.
	self icon: GLMUIThemeExtraIcons glamorousOver.
]
