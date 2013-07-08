Class {
	#name : #ACDAnnouncerBrowser,
	#superclass : #GLMCompositePresentation,
	#instVars : [
		'debugger'
	],
	#category : #'ACD-Glamour-Interface'
}

{ #category : #building }
ACDAnnouncerBrowser >> announcementIn: aComposite [ 

	"Not such a nice way to reuse the code"
	GTObjectVariablesBrowser new variablesIn: aComposite.
	aComposite presentations last 
		title: 'Announcement';
		display: [ :aSession | aSession announcement gtInspectorRetrieveVariableValuePairs ];
		selectionAct: [ :aPresentation |  aPresentation selection explore] on: $i entitled: 'Explore'
]

{ #category : #building }
ACDAnnouncerBrowser >> announcerIn: aComposite [ 

	"Not such a nice way to reuse the code"
	GTObjectVariablesBrowser new variablesIn: aComposite.
	aComposite presentations last 
		title: 'Announcer';
		display: [ :aSession | aSession announcer gtInspectorRetrieveVariableValuePairs ];
		selectionAct: [ :aPresentation |  aPresentation selection explore] on: $i entitled: 'Explore' 


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

{ #category : #private }
ACDAnnouncerBrowser >> highlightColorForSubscription: aSubscription [ 

	^ self session executingSubscription == aSubscription 
		ifTrue: [Color lightGray] 
		ifFalse: [Color transparent] 
]

{ #category : #'building actions' }
ACDAnnouncerBrowser >> installSubscriptionsActionsIn: aPresentation [ 

	self debugger installActionsForRootPragmas: { #ACDSubscriptionDebuggingAction } in: aPresentation
]

{ #category : #private }
ACDAnnouncerBrowser >> printAnnouncementTypeFor: anAnnouncementType [
 
	^ anAnnouncementType isCollection 
		ifTrue: [
			String streamContents: [:s | anAnnouncementType printElementsOn: s]] 
		ifFalse: [
			anAnnouncementType printString]
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
		display: [ :aSession | aSession activeSubscriptions ];
		column: 'Announcement Type' evaluated: [ :aSubscription | 
			self printAnnouncementTypeFor: aSubscription announcementClass];
		column: 'Action' evaluated: [ :aSubscription | 
			aSubscription action printString ];
		textBackgroundColor: [ :aSubscription |
			self highlightColorForSubscription: aSubscription ];
		selectionAct: [:each |  each selection explore] on: $i entitled: 'Explore';
		with: [ :presentation |
			self installSubscriptionsActionsIn: presentation ]
]
