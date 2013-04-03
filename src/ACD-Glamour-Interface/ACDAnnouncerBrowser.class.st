Class {
	#name : #ACDAnnouncerBrowser,
	#superclass : #GLMCompositePresentation,
	#instVars : [
		'debugger'
	],
	#category : #'ACD-Glamour-Interface'
}

{ #category : #'building actions' }
ACDAnnouncerBrowser >> addStepToNextSubscriptionActionFor: aPresentation to: aCollection [
	self session hasMoreActiveSubscriptions
		ifTrue: [ 
			aCollection
				add:
					(GLMGenericAction new
						action: [ 
									self nextSubscription.
									self debugger announce: ACDAnnouncerUpdate ];
						title: 'Next subscription';
						icon: GLMUIThemeExtraIcons glamorousOver;
						yourself) ]
]

{ #category : #building }
ACDAnnouncerBrowser >> announcementIn: aComposite [ 
			
	"Not such a nice way to reuse code"
	GTObjectVariablesBrowser new variablesIn: aComposite.
	aComposite presentations last 
		title: 'Announcement';
		display: [ :aSession | aSession announcement gtInspectorRetrieveVariableValuePairs ];
		selectionAct: [:each  :value|  each selection explore] on: $i entitled: 'Explore' 
			
	"aComposite dynamic 
		title: 'Announcement';
		display: [:aSession | 
				GTObjectVariablesBrowser new browser 
					noTitle; 
					startOn: aSession announcement]."
]

{ #category : #building }
ACDAnnouncerBrowser >> announcerIn: aComposite [ 

	"Not such a nice way to reuse the code"
	GTObjectVariablesBrowser new variablesIn: aComposite.
	aComposite presentations last 
		title: 'Announcer';
		display: [ :aSession | aSession announcer gtInspectorRetrieveVariableValuePairs ];
		selectionAct: [:each  :value|  each selection explore] on: $i entitled: 'Explore' 

	"|announcerPresentation|
	
	announcerPresentation := aComposite dynamic 
		title: 'Announcer';
		display: [:aSession | 
				GTObjectVariablesBrowser new browser noTitle; startOn: aSession announcer]."

]

{ #category : #building }
ACDAnnouncerBrowser >> componentsIn: aComposite [ 

	self 
		subscriptionsIn: aComposite;
		announcementIn: aComposite;
		announcerIn: aComposite
]

{ #category : #building }
ACDAnnouncerBrowser >> compose [

	self tabulator with: [:browser | 
		browser row: #components.
		browser transmit to: #components; andShow: [:aComposite | 
			self componentsIn: aComposite ].
		
		browser transmit 
			to: #components port: #selection; 
			from: #components port: #entity ;
			when: [ :aSession | aSession notNil ];
			transformed: [ :aSession |  aSession executingSubscription  ].
		
		browser transmit from: #components port: #strongSelection; toOutsidePort: #selection.
		
		"browser transmit from: #components port: #selection; toWatcher; andShow: [:a |
			a dynamic display: [:anObject | GLMTextPresentation  new ]]"].
				"GTInspector startOn: anObject ] ] ]."
	

]

{ #category : #accessing }
ACDAnnouncerBrowser >> debugger [

	^ debugger
]

{ #category : #accessing }
ACDAnnouncerBrowser >> debugger: anObject [

	debugger := anObject 
]

{ #category : #'building actions' }
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

{ #category : #'building actions' }
ACDAnnouncerBrowser >> installInspectActionsIn: aPresentation [ 

	aPresentation 
		selectionAct: [:each  :value|  each selection explore] on: $i entitled: 'Explore' 

]

{ #category : #'building actions' }
ACDAnnouncerBrowser >> installSubscriptionsActionsIn: aPresentation [ 

	aPresentation dynamicActions: [ :presentation || newActions |
		newActions := OrderedCollection new.
		self addStepToNextSubscriptionActionFor: aPresentation to: newActions.
		newActions ].
	self installInspectActionsIn: aPresentation 
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

{ #category : #building }
ACDAnnouncerBrowser >> subscriptionsIn: aComposite [ 

	aComposite table
		title: 'Subscriptions';
		showOnly: 100;
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
		 with: [ :presentation |
			self installSubscriptionsActionsIn: presentation ]
]
