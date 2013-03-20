"
I am an object use to test adaptations that send/receive messages
"
Class {
	#name : #ObjectPerformingSend,
	#superclass : #Object,
	#category : #'ACD-Tests'
}

{ #category : #'as yet unclassified' }
ObjectPerformingSend >> action [

]

{ #category : #'as yet unclassified' }
ObjectPerformingSend >> doAction [

	self action.
]

{ #category : #'as yet unclassified' }
ObjectPerformingSend >> doExternalAction [

	ObjectPerformingSend new printString.
]
