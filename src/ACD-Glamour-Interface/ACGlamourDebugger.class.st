Class {
	#name : #ACGlamourDebugger,
	#superclass : #GLMCompositePresentation,
	#category : #'ACD-Glamour-Interface'
}

{ #category : #opening }
ACGlamourDebugger class >> openAndInitializeSessionWith: sessionInitializationBlock [

	| process errorWasInUIProcess |
	process := Processor activeProcess.
	errorWasInUIProcess := UIManager default spawnNewProcessIfThisIsUI: process.
	
	WorldState
		addDeferredUIMessage: [[| session |
					
			
			session := (self spanSessionForContext: process suspendedContext fromProcess: process)
				errorWasInUIProcess: errorWasInUIProcess.
			sessionInitializationBlock value: session.
				
			self openOn: session.]
				on: Error
				do: [:ex | ex debug  "Debugger primitiveError: 'Orginal error: ' , 'ACD halt' , '.
	Smalltalk tools debugger error: '
							, ([ex description]
									on: Error
									do: ['a ' , ex class printString]) , ':'"]].

	process suspend.
]

{ #category : #opening }
ACGlamourDebugger class >> openOn: aSession [ 

	self new openOn: aSession
]

{ #category : #opening }
ACGlamourDebugger class >> openOnSender: senderContext [ 

	self openAndInitializeSessionWith: [:aSession | 
		aSession 
			initializeSenderContext: senderContext ]
]

{ #category : #opening }
ACGlamourDebugger class >> openOnSender: senderContext announcer: announcerContext [

	self openAndInitializeSessionWith: [:aSession | 
		aSession 
			initializeSenderContext: senderContext 
			announcerContext: announcerContext ]
]

{ #category : #opening }
ACGlamourDebugger class >> openOnSender: senderContext announcer: announcerContext receiver: receiverContext [

	self openAndInitializeSessionWith: [:aSession | 
		aSession 
			initializeSenderContext: senderContext 
			announcerContext: announcerContext 
			receiverContext: receiverContext ]
]

{ #category : #private }
ACGlamourDebugger class >> sessionClass [

	^ ACDebugSession 
]

{ #category : #accessing }
ACGlamourDebugger class >> spanSessionForContext: aContext fromProcess: aProcess [

	^ self sessionClass process: aProcess context: aContext 
]

{ #category : #actions }
ACGlamourDebugger >> actOnBrowserClosing: ann [

	self session terminate
]

{ #category : #building }
ACGlamourDebugger >> announcerIn: composite [

	composite dynamic
		display: [ :each | 
			GTInspector new first
				noTitle;
				noActions;
				showFirst: [ :a | a custom: (ACDAnnouncerBrowser new debugger: self; startOn: each) ];
				startOn: each ]

	"composite table
		title: 'Notifications';
		showOnly: 50;
		display: [ :announcerContext | announcerContext receiver subscriptions acdSubscriptions ];
		column: 'Type' evaluated: [:subscription | 
			subscription announcementClass printString ];
		column: 'Action' evaluated: [:subscription | 
			subscription action printString ]"
"		icon: [ :each |
			each value class theNonMetaClass browserIcon
				ifNotNil: [ OBMorphicIcons iconNamed: each value class theNonMetaClass browserIcon ] ];"

	"composite custom: ACDAnnouncerBrowser new first noTitle; noActions."

]

{ #category : #accessing }
ACGlamourDebugger >> browser [ 
	^ self presentations first
]

{ #category : #building }
ACGlamourDebugger >> compose [

	self title: 'Announcer Centric Debugger'.
	self tabulator with: [:browser | 
		browser
			column: [ :column | 
						column
							row: #sender;
							row: #announcer;
							row: #receiver].
		browser transmit
			to: #sender;
			transformed: [:session | session senderContext];
			andShow: [ :composite | self senderIn: composite ].
		browser transmit
			to: #announcer;
			"transformed: [:session | session announcerContext];"
			andShow: [ :composite | self announcerIn: composite ].
		browser transmit
			to: #receiver;
			transformed: [:session | session receiverContext];
			andShow: [ :composite | self receiverIn: composite ].
			
		browser transmit
			from: #sender port: #entity;
			to: #sender port: #selectionInterval;
			transformed: [:senderContext | self session pcRangeForContext: senderContext].
		browser transmit
			from: #receiver port: #entity;
			to: #receiver port: #selectionInterval;
			transformed: [:receiverContext | self session pcRangeForContext: receiverContext].
		 ].
	self on: GLMBrowserClosing send: #actOnBrowserClosing: to: self.
]

{ #category : #building }
ACGlamourDebugger >> installCodeActionsFor: aPresentation [

	self installWhereIsActionFor: aPresentation.

]

{ #category : #building }
ACGlamourDebugger >> installWhereIsActionFor: aPresentation [ 

	aPresentation 
		act: [ :textPresentation :context | 
			textPresentation selectionInterval: (self session pcRangeForContext:  context) ]
		icon: GLMUIThemeExtraIcons glamorousSearch 
		on: $w
		entitled: 'Where is?'

]

{ #category : #building }
ACGlamourDebugger >> receiverIn: composite [

	composite custom: (ACDReceiverBrowser new debugger: self)

	"composite smalltalkCode
		title: [:receiverContext | GTInspector new printObjectAsAnItem: receiverContext receiver ];
		doItReceiver: [:receiverContext | receiverContext receiver ];
		format: [:receiverContext | receiverContext  sourceCode ];
		smalltalkClass: [ :receiverContext | receiverContext methodClass ];
		with: [ :code | self installCodeActionsFor: code ]"

	"composite custom: ACDReceiverBrowser new first noTitle; noActions."
]

{ #category : #building }
ACGlamourDebugger >> resume [

	self session resume.
	self session clear.
	self browser close
]

{ #category : #building }
ACGlamourDebugger >> senderIn: composite [

	composite smalltalkCode
		title: [:senderContext | GTInspector new printObjectAsAnItem: senderContext receiver ];
		doItReceiver: [:senderContext | senderContext receiver ];
		format: [:senderContext |  senderContext  sourceCode asText makeSelectorBold];
		smalltalkClass: [ :senderContext | senderContext methodClass ];
		with: [ :code | self installCodeActionsFor: code ]

	"composite custom: ACDSenderBrowser new first noActions; noTitle "
]

{ #category : #accessing }
ACGlamourDebugger >> session [

	^ (self browser pane port: #entity) value
]

{ #category : #actions }
ACGlamourDebugger >> updateReceiver [

	((self browser paneNamed: #receiver) port: #entity) value: self session receiverContext.
	(self browser paneNamed: #receiver)  update.
]

{ #category : #events }
ACGlamourDebugger >> windowIsClosing [ 

	self announce: GLMBrowserClosing new
]
