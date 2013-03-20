Class {
	#name : #ACDAnnouncerBrowser,
	#superclass : #GLMCompositePresentation,
	#instVars : [
		'debugger'
	],
	#category : #'ACD-Glamour-Interface'
}

{ #category : #'as yet unclassified' }
ACDAnnouncerBrowser >> announcementIn: aComposite [ 
			
	aComposite dynamic 
		title: 'Announcement';
		display: [:aSession | 
				GTObjectVariablesBrowser new browser 
					noTitle; 
					startOn: aSession announcement].
]

{ #category : #'as yet unclassified' }
ACDAnnouncerBrowser >> announcerIn: aComposite [ 
	|announcerPresentation|
	
	announcerPresentation := aComposite dynamic 
		title: 'Announcer';
		display: [:aSession | 
				GTObjectVariablesBrowser new browser noTitle; startOn: aSession announcer].
			
	self installAnnouncerActionsIn: announcerPresentation. 
]

{ #category : #'as yet unclassified' }
ACDAnnouncerBrowser >> componentsIn: aComposite [ 

	self 
		subscriptionsIn: aComposite;
		announcementIn: aComposite;
		announcerIn: aComposite
]

{ #category : #'as yet unclassified' }
ACDAnnouncerBrowser >> compose [

	self tabulator with: [:browser | 
		browser row: #components.
		browser transmit to: #components; andShow: [:aComposite | 
			self componentsIn: aComposite ].
		browser transmit from: #components; toOutsidePort: #selection ].
	

]

{ #category : #accessing }
ACDAnnouncerBrowser >> debugger [

	^ debugger
]

{ #category : #accessing }
ACDAnnouncerBrowser >> debugger: anObject [

	debugger := anObject 
]

{ #category : #'as yet unclassified' }
ACDAnnouncerBrowser >> installAnnouncerActionsIn: aPresentation [ 

	aPresentation 
		act: [		
			self session announcer haltWhenAnnoucerIsNotified.
			self debugger resume ] 
		entitled: 'Halt when notified by anyone'.
		
	aPresentation 
		act: [		
			self session announcer haltWhenAnnoucerIsNotifiedBy: self session sender.
			self debugger resume ] 
		entitled: 'Halt when notified by sender'
]

{ #category : #'as yet unclassified' }
ACDAnnouncerBrowser >> nextSubscription [

	self session stepToNextSubscription
]

{ #category : #'as yet unclassified' }
ACDAnnouncerBrowser >> printAnnouncementTypeFor: anAnnouncementType [
 
	^ anAnnouncementType isCollection 
		ifTrue: [
			String streamContents: [:s | anAnnouncementType printElementsOn: s]] 
		ifFalse: [
			anAnnouncementType printString]
]

{ #category : #'as yet unclassified' }
ACDAnnouncerBrowser >> printReceiverFor: aSubscription [

	^ GTInspector new printObjectAsAnItem: aSubscription subscriber
]

{ #category : #accessing }
ACDAnnouncerBrowser >> session [

	^ self debugger session 
]

{ #category : #'as yet unclassified' }
ACDAnnouncerBrowser >> subscriptionsIn: aComposite [ 

	aComposite table
		title: 'Subscriptions';
		showOnly: 50;
		display: [ :aSession | aSession allSubscriptions ];
		column: 'Announcement Type' evaluated: [:subscription | 
			self printAnnouncementTypeFor: subscription announcementClass];
		"column: 'Receiver' evaluated: [:subscription | 
			self printReceiverFor: subscription  ];"
		column: 'Action' evaluated: [:subscription | 
			subscription action printString ];
		textBackgroundColor: [:subscription :aSession| aSession executingSubscription == subscription 
			ifTrue: [Color lightGray] 
			ifFalse: [Color transparent ] ];
		act: [ :aPresentation |
			self nextSubscription. 
			aPresentation update.
			self debugger updateReceiver.
			] icon: GLMUIThemeExtraIcons glamorousOver entitled: 'Next subscription' 
		"icon: [ :each |
			each value class theNonMetaClass browserIcon
				ifNotNil: [ OBMorphicIcons iconNamed: each value class theNonMetaClass browserIcon ] ]".
]
