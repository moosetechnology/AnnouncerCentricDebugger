Class {
	#name : #ACDStepToNextSubscriptionDebugAction,
	#superclass : #MessageSendDebugAction,
	#category : #'ACD-Glamour-Interface'
}

{ #category : #'as yet unclassified' }
ACDStepToNextSubscriptionDebugAction >> appliesToContext: aContext [

	^ self session hasMoreActiveSubscriptions
]

{ #category : #'as yet unclassified' }
ACDStepToNextSubscriptionDebugAction >> defaultReceiver [

	^ self session
]

{ #category : #'as yet unclassified' }
ACDStepToNextSubscriptionDebugAction >> initialize [

	self action: #stepToNextSubscription.
	self label: 'Next subscription'.
	self icon: GLMUIThemeExtraIcons glamorousOver.
]
