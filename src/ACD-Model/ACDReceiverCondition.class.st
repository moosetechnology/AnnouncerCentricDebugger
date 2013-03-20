Class {
	#name : #ACDReceiverCondition,
	#superclass : #ACDHaltCondition,
	#instVars : [
		'senderContext',
		'announcerContext',
		'receiverContext'
	],
	#category : #'ACD-Model'
}

{ #category : #'instance creation' }
ACDReceiverCondition class >> check: aBlock [

	^ ACDReceiverBlockCondition new check: aBlock
]

{ #category : #initialization }
ACDReceiverCondition >> announcerContext: anAnnouncerContext [

	announcerContext := anAnnouncerContext.
]

{ #category : #initialization }
ACDReceiverCondition >> receiverContext: aReceiverContext [

	receiverContext := aReceiverContext
]

{ #category : #initialization }
ACDReceiverCondition >> senderContext: aSenderContext [ 

	senderContext := aSenderContext.
]
