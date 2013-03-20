Class {
	#name : #TestForAnnouncers,
	#superclass : #TestCase,
	#category : #'ACD-Tests'
}

{ #category : #'as yet unclassified' }
TestForAnnouncers class >> testObjectPerformingSendToExternaObject [
	"A notification is raised when an object sends a mesage to another object"
	|target aMetaObject announcer|
	
	target := ObjectPerformingSend new.	
	
	aMetaObject := BFBehavioralMetaObject new.
	aMetaObject 
		when: #printString
		isSentDo: [:sender :receiver :selector :arguments  |  
			self halt. ].
	aMetaObject bindTo: target.
	
	target doExternalAction.
]

{ #category : #'as yet unclassified' }
TestForAnnouncers class >> testObjectPerformingSendToSelf [
	"A notification is raised when an object sends a mesage to self"
	|target aMetaObject announcer|
	
	target := ObjectPerformingSend new.	
	
	aMetaObject := BFBehavioralMetaObject new.
	aMetaObject 
		when: #action
		isSentDo: [:sender :receiver :selector :arguments  |  
			self halt. ].
	aMetaObject bindTo: target.
	
	target doAction.
]

{ #category : #'as yet unclassified' }
TestForAnnouncers class >> testObjectReceivingMessage [
	"A notification is raised when a certain message is sent to an object."
	|target aMetaObject|
	
	target := ObjectPerformingSend new.	
	
	aMetaObject := BFBehavioralMetaObject new.
	aMetaObject 
		when: #action
		isReceivedDo: [:sender :receiver :selector :arguments  |  
			self halt. ].
	aMetaObject bindTo: target.
	
	target doAction.

]

{ #category : #'as yet unclassified' }
TestForAnnouncers >> testAnnouncerReceivesAnnouncement [
	"Test for when an announcer receives an announcement
	that it should propagate to its subscriptions."
	|aMetaObject announcerToBeAdapted counter|
	
 	announcerToBeAdapted := Announcer new.
	counter := 0.
	
	aMetaObject := ACDBehavioralMetaObject new.
	aMetaObject 
		whenAnnoucerIsNotifiedDo: [ counter := counter + 1 ].
	aMetaObject bindTo: announcerToBeAdapted.
	
	self assert: counter = 0.
	announcerToBeAdapted announce: Announcement.
	self assert: counter = 1.
	announcerToBeAdapted announce: Announcement.
	self assert: counter = 2.

	aMetaObject unbindFrom: announcerToBeAdapted
]

{ #category : #'as yet unclassified' }
TestForAnnouncers >> testAnnouncerReceivesCustomAnnouncement [
	"Test for when an announcer receives a certain type of announcement
	that it should propagate to its subscriptions."
	|aMetaObject announcerToBeAdapted counter|
	
 	announcerToBeAdapted := Announcer new.
	counter := 0.
	
	aMetaObject := ACDBehavioralMetaObject new.
	aMetaObject 
		whenAnnoucerIsNotifiedWith: CustomAnnouncement 
		do: [ counter := counter + 1].	
	aMetaObject bindTo: announcerToBeAdapted.
	
	self assert: counter = 0.
	announcerToBeAdapted announce: Announcement.
	announcerToBeAdapted announce: CustomAnnouncement.
	announcerToBeAdapted announce: Announcement.
	self assert: counter = 1.
	
	aMetaObject unbindFrom: announcerToBeAdapted

]

{ #category : #'as yet unclassified' }
TestForAnnouncers >> testClientInvokesAnnouncer [
	"Test for when a domanin object invokes an announcer"
	|objectToBeAdapted aMetaObject counter|
	
	objectToBeAdapted := ObjectInvokingAnnouncer new.	
	counter := 0.
	
	aMetaObject := ACDBehavioralMetaObject new.
	aMetaObject 
		whenClientInvokesAnnouncerDo: [ self halt. counter := counter + 1 ].
	aMetaObject bindTo: objectToBeAdapted.
	
	self assert: counter = 0.
	objectToBeAdapted invokeDefaultAnnouncer.
	self assert: counter = 1.
	objectToBeAdapted invokeDefaultAnnouncer.
	self assert: counter = 2.
	
	aMetaObject unbindFrom: objectToBeAdapted.

]

{ #category : #'as yet unclassified' }
TestForAnnouncers >> testClientInvokesAnnouncerByType [
	"Test for when a domanin object invokes an announcer having a given class"
	|objectToBeAdapted aMetaObject counter|
	
	objectToBeAdapted := ObjectInvokingAnnouncer new.
	counter := 0.
	
	aMetaObject := ACDBehavioralMetaObject new.
	aMetaObject 
		whenClientInvokesAnnouncerOfType: CustomAnnouncer  
		do: [ counter := counter + 1 ].

	aMetaObject bindTo: objectToBeAdapted.
	
	self assert: counter = 0.
	objectToBeAdapted invokeDefaultAnnouncer.
	objectToBeAdapted invokeCustomAnnouncer.
	self assert: counter = 1.
	
	aMetaObject unbindFrom: objectToBeAdapted 
]

{ #category : #'as yet unclassified' }
TestForAnnouncers >> testClientInvokesCustomAnnouncerInstace [
	"Test for when a domanin object invokes a certain instance of an announcer"
	|target aMetaObject announcer counter|
	
	target := ObjectInvokingAnnouncer new.
	announcer := Announcer new.
	counter := 0.
	
	aMetaObject := ACDBehavioralMetaObject new.
	aMetaObject 
		whenClientInvokesAnnouncerInstance: announcer do: [ counter:= counter + 1 ].
	aMetaObject bindTo: target.
	
	self assert: counter = 0.
	target invokeDefaultAnnouncer.
	target invokeAnnouncer: announcer.
	target invokeCustomAnnouncer.
	self assert: counter = 1.
	
	aMetaObject unbindFrom: target 

]

{ #category : #'as yet unclassified' }
TestForAnnouncers >> testClientReceivesAnnouncement [
	"Test for when a domain object receives a message
	as a direct result of an announcement."
	|objectToBeAdapted aMetaObject announcer counter|
	
	objectToBeAdapted := ObjectReceivingAnnouncement new.	
 	announcer := Announcer new.
	announcer on: Announcement send: #doSomething to: objectToBeAdapted.
	counter := 0.
	
	aMetaObject := ACDBehavioralMetaObject new.
	aMetaObject 
		whenObjectReceivesAnnouncementDo: [ counter := counter + 1 ].
	aMetaObject bindTo: objectToBeAdapted.
	
	self assert: counter = 0.
	announcer announce: Announcement.
	self assert: counter = 1.
	
	aMetaObject unbindFrom: objectToBeAdapted

]
