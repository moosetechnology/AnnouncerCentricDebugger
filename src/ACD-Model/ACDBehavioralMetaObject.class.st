Class {
	#name : #ACDBehavioralMetaObject,
	#superclass : #BFBehavioralMetaObject,
	#category : #'ACD-Model'
}

{ #category : #'as yet unclassified' }
ACDBehavioralMetaObject >> stackFilterFor: aContext [ 

	^ ACDStackFilter forContext: aContext 
]

{ #category : #'as yet unclassified' }
ACDBehavioralMetaObject >> whenAnnoucerIsNotifiedDo: aBlock [
	"Register an event to be executed when an announcer receives an announcement that should be propagated to its subscriptions."
	self when: #announce: isReceivedDo: [:context | |senderContext|
		senderContext := (self stackFilterFor: context sender) filterBifrostAdaptations; result.
		aBlock cull: senderContext cull: context ]
]

{ #category : #'as yet unclassified' }
ACDBehavioralMetaObject >> whenAnnoucerIsNotifiedWith: announcementType do: aBlock [
	"Register an event to be executed when an announcer receives an announcement 
	of the given type that should be propagated to its subscriptions."
	
	"Temporary implementation."
	self when: #announce: isReceivedDo: [:arguments  |  
			(arguments at: 1) announcementType == announcementType ifTrue: [
				"This is not good -> reimplement"
				aBlock value ] ].
]

{ #category : #'as yet unclassified' }
ACDBehavioralMetaObject >> whenClientInvokesAnnouncerDo: aBlock [
	"Register an event to be executed when a domanin object invokes an announcer."
	
	self when: #announce: isSentDo: [ :context |
		aBlock cull: context].
]

{ #category : #'as yet unclassified' }
ACDBehavioralMetaObject >> whenClientInvokesAnnouncerInstance: anAnnouncer do: aBlock [
	"Register an event to be executed when a domanin object invokes 
	a certain instance of an announcer."
	
	self when: #announce: isSentDo: [:receiver |
			receiver == anAnnouncer ifTrue: [		
				"This is not good -> reimplement"
				aBlock value] ].
]

{ #category : #'as yet unclassified' }
ACDBehavioralMetaObject >> whenClientInvokesAnnouncerOfType: announcerClass do: aBlock [
	"Register an event to be executed when a domanin object invokes an announcer 
	having a given class."
	
	self when: #announce: isSentDo: [ :receiver  |  
			receiver class == announcerClass ifTrue: [		
				"This is not good -> reimplement"
				aBlock value ] ].
]

{ #category : #'as yet unclassified' }
ACDBehavioralMetaObject >> whenObjectReceivesAnnouncementDo: aBlock [
	"Register an event to be executed when a domanin object receives a message
	as a direct result of an announcement."
	
	self when: BFMessageReceiveEvent new
		do: [ :context :sender :receiver :arguments  |  |announcerContext|
			"GTDebugger debugCurrentProcess."
			
			announcerContext := (self stackFilterFor: context sender) locateAnnouncerEntryPoint.
			announcerContext ifNotNil: [
				aBlock cull: announcerContext sender cull: announcerContext cull: context ] ]
]
