Class {
	#name : #ACDReceiverBlockCondition,
	#superclass : #ACDReceiverCondition,
	#instVars : [
		'condition'
	],
	#category : #'ACD-Model'
}

{ #category : #'as yet unclassified' }
ACDReceiverBlockCondition >> check [

	^ condition cull: senderContext cull: announcerContext cull: receiverContext 
]

{ #category : #'as yet unclassified' }
ACDReceiverBlockCondition >> check: aBlock [

	condition := aBlock 
]
