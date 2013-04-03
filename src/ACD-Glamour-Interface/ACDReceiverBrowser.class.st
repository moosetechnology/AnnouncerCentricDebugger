Class {
	#name : #ACDReceiverBrowser,
	#superclass : #GLMCompositePresentation,
	#instVars : [
		'debugger'
	],
	#category : #'ACD-Glamour-Interface'
}

{ #category : #actions }
ACDReceiverBrowser >> actOnBrowserClosing: ann [
	
	self removeActions 
]

{ #category : #building }
ACDReceiverBrowser >> addChangeDebuggerActionFor: aPresentation to: aCollection [
	
	(self debugger debuggersForContext: self session context)
		do: [ :aDebuggerClass | 
			aCollection
				add:
					(GLMGenericAction new
						action: [ self debugger debug: self session context using: aDebuggerClass ];
						title: aDebuggerClass defaultTitle;
						category: 'Available Debuggers';
						yourself) ]

]

{ #category : #building }
ACDReceiverBrowser >> addDynamicActionsFor: aPresentation to: aCollection [

	(self session receiverContext = self session context and: [self session context willReturn]) ifFalse: [ 
		self addStepIntoActionFor: aPresentation to: aCollection.
		self addStepOverActionFor: aPresentation to: aCollection.
		self addStepThroughActionFor: aPresentation to: aCollection ].
	self addChangeDebuggerActionFor: aPresentation to: aCollection

]

{ #category : #building }
ACDReceiverBrowser >> addStepIntoActionFor: aPresentation to: aCollection [
	
	aCollection
		add:
			(GLMGenericAction new
				action: [ :presentation :context | 
							self session stepInto: context.
							self debugger announce: ACDReceiverUpdate ];
				icon: GLMUIThemeExtraIcons glamorousInto;
				title: 'Step into';
				yourself)	
]

{ #category : #building }
ACDReceiverBrowser >> addStepOverActionFor: aPresentation to: aCollection [
	
	aCollection
		add:
			(GLMGenericAction new
				action: [ :presentation :context | 
							self session stepOver: context.
							self debugger announce: ACDReceiverUpdate ];
				icon: GLMUIThemeExtraIcons glamorousOver;
				title: 'Step over';
				yourself)	

]

{ #category : #building }
ACDReceiverBrowser >> addStepThroughActionFor: aPresentation to: aCollection [ 
	
	aCollection
		add:
			(GLMGenericAction new
				action: [ :presentation :context | 
							self session stepThrough: context.
							self debugger announce: ACDReceiverUpdate ];
				icon: GLMUIThemeExtraIcons glamorousThrough;
				title: 'Step through';
				yourself)	
]

{ #category : #building }
ACDReceiverBrowser >> compose [

"	self tabulator with: [:browser | 
		browser column: #main.
		
		browser transmit
			to: #main;
			andShow: [ :composite | 
				composite smalltalkCode
					when: [:value | value notNil ];
					title: [:receiverContext | GTInspector new printObjectAsAnItem: receiverContext receiver ];
					doItReceiver: [:receiverContext | receiverContext receiver ];	
					format: [:receiverContext | receiverContext  sourceCode asText makeSelectorBold];
					smalltalkClass: [ :receiverContext | receiverContext methodClass ];
					with: [ :presentation | self installActionsFor: presentation ] ].
				
		browser transmit
			fromOutsidePort: #selectionInterval;			
			to: #main port: #selectionInterval: ]"



	self smalltalkCode
		when: [:value | value notNil ];
		title: [:receiverContext | GTInspector new printObjectAsAnItem: receiverContext receiver ];
		doItReceiver: [:receiverContext | receiverContext receiver ];
		format: [:receiverContext | receiverContext  sourceCode asText makeSelectorBold];
		smalltalkClass: [ :receiverContext | receiverContext methodClass ];
		act: [:each|  each entity receiver explore] on: $i entitled: 'Explore';
		with: [ :presentation | self installActionsFor: presentation ]
		"updateOn: Announcement from: self."
	
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

	self installDynamicActionsFor: aPresentation.
	self installWhereIsActionFor: aPresentation.
	self installResumeActionFor: aPresentation.
	"self installAnnouncementReceivedActionsFor: aPresentation"
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
ACDReceiverBrowser >> installDynamicActionsFor: aPresentation [

	aPresentation dynamicActions: [ :presentation || newActions |
		newActions := OrderedCollection new.
		self addDynamicActionsFor: presentation to: newActions.
		newActions ].
]

{ #category : #building }
ACDReceiverBrowser >> installResumeActionFor: aPresentation [
	
	aPresentation 
		act: [ self debugger resume ]
		icon: GLMUIThemeExtraIcons glamorousPlay
		entitled: 'Resume' 
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

{ #category : #building }
ACDReceiverBrowser >> registerActions [

	self session ifNotNil: [ :aSession |
		aSession
			"when: #restart send: #updateRestart to: self;
			when: #resume send: #updateResume to: self;"
			when: #stepInto send: #updateStepInto to: self;
			when: #stepOver send: #updateStepOver to: self;
			when: #stepThrough send: #updateStepThrough to: self
			"when: #contextChanged send: #updateContextChanged to: self"  ]
]

{ #category : #building }
ACDReceiverBrowser >> removeActions [

	self session ifNotNil: [ :aSession |
		aSession  
			"removeActionsForEvent: #restart;
			removeActionsForEvent: #resume;"
			removeActionsForEvent: #stepInto;
			removeActionsForEvent: #stepOver;
			removeActionsForEvent: #stepThrough
			"removeActionsForEvent:#contextChanged" ]. 
]

{ #category : #accessing }
ACDReceiverBrowser >> session [

	^ self debugger session 
]
