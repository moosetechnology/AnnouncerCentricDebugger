Class {
	#name : #ACDReceiverBrowser,
	#superclass : #GTInspector,
	#instVars : [
		'debugger'
	],
	#category : #'ACD-Glamour-Interface'
}

{ #category : #building }
ACDReceiverBrowser >> compose [

	self smalltalkCode
		title: [:receiverContext | GTInspector new printObjectAsAnItem: receiverContext receiver ];
		doItReceiver: [:receiverContext | receiverContext receiver ];
		format: [:receiverContext | receiverContext  sourceCode ];
		smalltalkClass: [ :receiverContext | receiverContext methodClass ];
		with: [ :presentation | self installActionsFor: presentation ]
]

{ #category : #accessing }
ACDReceiverBrowser >> debugger [

	^ debugger
	
]

{ #category : #accessing }
ACDReceiverBrowser >> debugger: anObject [

	debugger := anObject 
	
]

{ #category : #building }
ACDReceiverBrowser >> installActionsFor: aPresentation [

	self installWhereIsActionFor: aPresentation.
	self installAnnouncementReceivedActionsFor: aPresentation.
]

{ #category : #building }
ACDReceiverBrowser >> installAnnouncementReceivedActionsFor: aPresentation [

	aPresentation 
		act: [		
			self session receiver haltWhenClientReceivesAnnouncement.
			self debugger resume ] 
		entitled: 'from anyone'
		categorized: 'Halt when an announcement is received'.
		
	aPresentation 
		act: [		
			self session receiver haltWhenObjectReceivesAnnouncementFromSender: self session sender.
			self debugger resume ] 
		entitled: 'from the same sender'
		categorized: 'Halt when an announcement is received'.
		
	aPresentation 
		act: [		
			self session receiver haltWhenObjectReceivesAnnouncementFromAnnouncer: self session announcer.
			self debugger resume ] 
		entitled: 'using the same announcer'
		categorized: 'Halt when an announcement is received'.
		
	aPresentation 
		act: [		
			self session receiver haltWhenObjectReceivesAnnouncementFromSender: self session sender andAnnouncer: self session announcer.
			self debugger resume ] 
		entitled: 'from the same sender using the same announcer'
		categorized: 'Halt when an announcement is received'.
		
	"aPresentation 
		act: [		
			self session receiver haltWhenClientReceivesAnnouncementOfType: self session announcement announcementType.
			self debugger resume ] 
		entitled: 'Halt when an announcement is received having the same type'.
		
	aPresentation 
		act: [		
			self session receiver haltWhenClientReceivesAnnouncement.
			self debugger resume ] 
		entitled: 'Halt when an announcement is received having the type...'.
		
	aPresentation 
		act: [		
			self session receiver haltWhenClientReceivesAnnouncement.
			self debugger resume ] 
		entitled: 'Halt when an announcement is received and condition holds'.
		"
	
]

{ #category : #building }
ACDReceiverBrowser >> installAnnouncerInvokedActionsFor: aPresentation [

	aPresentation 
		act: [		
			self session receiver haltWhenClientReceivesAnnouncement.
			self debugger resume ] 
		entitled: 'from anyone'
		categorized: 'Halt when an announcement is received'.
	
]

{ #category : #building }
ACDReceiverBrowser >> installWhereIsActionFor: aPresentation [ 

	aPresentation 
		act: [ :textPresentation :context | 
			textPresentation selectionInterval: (self session pcRangeForContext:  context) ]
		icon: GLMUIThemeExtraIcons glamorousSearch 
		on: $w
		entitled: 'Where is?'
]

{ #category : #accessing }
ACDReceiverBrowser >> session [

	^ self debugger session 
]
