"
I am an object that just sends announcements to announcers
"
Class {
	#name : #ObjectInvokingAnnouncer,
	#superclass : #Object,
	#category : #'ACD-Tests'
}

{ #category : #'as yet unclassified' }
ObjectInvokingAnnouncer >> invokeAnnouncer: anAnnouncer [
	
	anAnnouncer announce: CustomAnnouncement
]

{ #category : #'as yet unclassified' }
ObjectInvokingAnnouncer >> invokeAnnouncer: anAnnouncer withAnnouncement: anAnnouncement [
		
	anAnnouncer announce: anAnnouncement
]

{ #category : #'as yet unclassified' }
ObjectInvokingAnnouncer >> invokeCustomAnnouncer [
	|announcer|
	
	announcer := CustomAnnouncer new.
	announcer announce: CustomAnnouncement
]

{ #category : #'as yet unclassified' }
ObjectInvokingAnnouncer >> invokeDefaultAnnouncer [
	|announcer|
	
	announcer := Announcer new.
	announcer announce: CustomAnnouncement
]
