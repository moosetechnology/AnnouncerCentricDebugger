Class {
	#name : #ACDStepToNextSubscriptionDebugAction,
	#superclass : #MessageSendDebugAction,
	#category : #'ACD-Glamour-Interface'
}

{ #category : #'as yet unclassified' }
ACDStepToNextSubscriptionDebugAction class >> acdActionType [
	<gtACDSubscriptionDebuggingAction>
]

{ #category : #testing }
ACDStepToNextSubscriptionDebugAction >> appliesToContext: aContext [

	^ self session hasMoreActiveSubscriptions
]

{ #category : #accessing }
ACDStepToNextSubscriptionDebugAction >> defaultReceiver [

	^ self session
]

{ #category : #'initialize-release' }
ACDStepToNextSubscriptionDebugAction >> initialize [

	self action: #stepToNextSubscription.
	self label: 'Next subscription'.
	self icon: GLMUIThemeExtraIcons glamorousOver.
]
