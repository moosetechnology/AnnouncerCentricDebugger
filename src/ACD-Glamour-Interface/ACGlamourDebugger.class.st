Class {
	#name : #ACGlamourDebugger,
	#superclass : #GTDebugger,
	#category : #'ACD-Glamour-Interface'
}

{ #category : #opening }
ACGlamourDebugger class >> debugBasedOnSession: aSession [
	|debugger|
	
	debugger := self new. 
	debugger process: aSession process controller: nil context: aSession context.
	debugger session errorWasInUIProcess: aSession errorWasInUIProcess.
	debugger open
]

{ #category : #accessing }
ACGlamourDebugger class >> defaultTitle [

	^ 'Announcer Centric Debugger'
]

{ #category : #testing }
ACGlamourDebugger class >> handlesContext: aContext [

	 ^ (self sessionClass stackFilterFor: aContext) locateAnnouncerEntryPoint notNil 
]

{ #category : #'tools registry' }
ACGlamourDebugger class >> registerToolsOn: registry [

	"Add ourselves to registry. See [Smalltalk tools]" 
	registry registerDebugger: self withRank: 10.
]

{ #category : #private }
ACGlamourDebugger class >> sessionClass [

	^ ACDDebugSession 
]

{ #category : #accessing }
ACGlamourDebugger class >> spanCompleteSessionForContext: aContext fromProcess: anInterruptedProcess [
	|session announcerContext|
	
	announcerContext := (ACDContextLocator forContext: aContext sender) locateAnnouncerEntryPoint.
	session := (self spanSessionForContext: aContext fromProcess: anInterruptedProcess).		
	session 
		initializeSenderContext: announcerContext sender 
		announcerContext: announcerContext 
		receiverContext: aContext.
	^ session
]

{ #category : #accessing }
ACGlamourDebugger class >> spanSessionForContext: aContext fromProcess: anInterruptedProcess [

	^ self sessionClass process: anInterruptedProcess context: aContext 
]

{ #category : #'building presentations' }
ACGlamourDebugger >> announcerIn: composite [

	composite custom:
			(GTInspector new first
				fixedSizePanes: 1; "Only one"
				noTitle;
				noActions;
				showFirst: [ :a | a custom: (ACDAnnouncerBrowser new debugger: self) ];
				yourself)

]

{ #category : #'building presentations' }
ACGlamourDebugger >> codePresentationIn: composite [

	^ composite smalltalkCode
		title: [ :aContext | GTInspector new printObjectAsAnItem: aContext receiver ];
		doItReceiver: [ :aContext | aContext receiver ];
		doItContext: [ :aContext | aContext ];
		format: [ :aContext | aContext  sourceCode];
		smalltalkClass: [ :aContext | aContext methodClass ];
		act: [:each |  each entity receiver explore] on: $e entitled: 'Explore'
]

{ #category : #'accessing context' }
ACGlamourDebugger >> currentContext [ 

	^ self interruptedContext
]

{ #category : #building }
ACGlamourDebugger >> debuggerStructureIn: browser [
	
	browser
		column: [ :column | 
			column
				row: #receiver;
				row: #announcer;
				row: #sender];
		column: #stack.
]

{ #category : #building }
ACGlamourDebugger >> debuggerTransmissionsIn: browser [

	browser transmit
			to: #receiver;
			when: [ :session | session notNil ];
			transformed: [:session | session context];
			andShow: [ :composite | self receiverIn: composite ].	
		browser transmit
			to: #announcer;
			andShow: [ :composite | self announcerIn: composite ].
		browser transmit
			to: #sender;
			transformed: [:session | session senderContext];
			andShow: [ :composite | self senderIn: composite ].
		browser transmit
			to: #stack;
			andShow: [ :composite | self stackIn: composite ]
]

{ #category : #'building actions' }
ACGlamourDebugger >> installReceiverActionsFor: aPresentation [

	self installActionsForRootPragmas: { #ACDReceiverDebuggingAction } in: aPresentation
]

{ #category : #'building actions' }
ACGlamourDebugger >> installSenderActionsFor: aPresentation [

	self installActionsForRootPragmas: { #ACDSenderDebuggingAction } in: aPresentation
]

{ #category : #initialization }
ACGlamourDebugger >> process: aProcess controller: aController context: aContext [

	self session: (self class spanCompleteSessionForContext: aContext fromProcess: aProcess)
]

{ #category : #'building presentations' }
ACGlamourDebugger >> receiverIn: composite [

	(self codePresentationIn: composite)
		initialize: [ :code | code selectionInterval: (self session selectedCodeRangeForContext: self currentContext) ];
		with: [ :code | self installReceiverActionsFor: code ]
]

{ #category : #accessing }
ACGlamourDebugger >> receiverSelectionInterval [

	^ self selectionIntervalForPane: #receiver
]

{ #category : #actions }
ACGlamourDebugger >> resume [

	self session resume.
	self session clear.
	self browser close
]

{ #category : #'accessing context' }
ACGlamourDebugger >> selectedContext [

	^ self interruptedContext
]

{ #category : #'building presentations' }
ACGlamourDebugger >> senderIn: composite [

	(self codePresentationIn: composite)
		initialize: [ :code | code selectionInterval: (self session selectedCodeRangeForContext: self session senderContext) ];
		with: [ :code | self installSenderActionsFor: code ]
]

{ #category : #'building presentations' }
ACGlamourDebugger >> stackIn: composite [

	composite list	
		title: 'Stack';
		showOnly: 50;
		display: #stack;
		format: [ :each | String streamContents: [:stream | each printDebugOn: stream ] ];
		selectionAct: [:each|  each selection explore] on: $i entitled: 'Explore'

]

{ #category : #updating }
ACGlamourDebugger >> updateReceiverCodeSelection [

	((self browser paneNamed: #receiver) 
		port: #selectionInterval) 
			value:  (self session selectedCodeRangeForContext:  self currentContext)
]

{ #category : #updating }
ACGlamourDebugger >> updateSenderCodeSelection [

	((self browser paneNamed: #sender) 
		port: #selectionInterval) 
			value:  (self session selectedCodeRangeForContext:  self session senderContext)
]
