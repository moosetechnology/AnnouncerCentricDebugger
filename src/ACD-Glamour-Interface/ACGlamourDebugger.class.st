Class {
	#name : #ACGlamourDebugger,
	#superclass : #GLMCompositePresentation,
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

{ #category : #opening }
ACGlamourDebugger class >> debugCurrentProcess [
	| process errorWasInUIProcess |
	process := Processor activeProcess.
	errorWasInUIProcess := UIManager default spawnNewProcessIfThisIsUI: process.
	
	WorldState
		addDeferredUIMessage: [[| session announcerContext |
				
				session := (self spanSessionForContext: process suspendedContext fromProcess: process)
				errorWasInUIProcess: errorWasInUIProcess.
				
				announcerContext := (ACDStackFilter forContext:  process suspendedContext sender sender) locateAnnouncerEntryPoint.
				
				session initializeSenderContext: announcerContext sender 
					announcerContext: announcerContext 
					receiverContext: process suspendedContext sender.
				session inspect.
				
				self openOn: session.
					
					] value.
				"on: Error
				do: [:ex | Debugger primitiveError: 'Orginal error: ' , 'ACD halt' , '.
	Smalltalk tools debugger error: '
							, ([ex description]
									on: Error
									do: ['a ' , ex class printString]) , ':']"
								
								].

	process suspend.
]

{ #category : #accessing }
ACGlamourDebugger class >> defaultTitle [

	^ 'Announcer Centric Debugger'
]

{ #category : #testing }
ACGlamourDebugger class >> handlesContext: aContext [

	"TODO: aContext sender sender
	aContext represents the context of the exception.
	we need the sender -> must improve"
	 ^ (self sessionClass stackFilterFor: aContext sender) locateAnnouncerEntryPoint notNil 
]

{ #category : #'class initialization' }
ACGlamourDebugger class >> initialize [ 
	super initialize.

	"Add ourselves to registry. See [Smalltalk tools]" 
	Smalltalk tools registerDebugger: self withRank: 10.
]

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
ACGlamourDebugger class >> spanCompleteSessionForContext: aContext fromProcess: anInterruptedProcess [
	|session announcerContext|
	
	announcerContext := (ACDStackFilter forContext: aContext sender) locateAnnouncerEntryPoint.
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

{ #category : #callbacks }
ACGlamourDebugger >> actOnAnnouncerUpdate [

	self 
		updateAnnouncer;
		updateStack;
		updateReceiver


]

{ #category : #callbacks }
ACGlamourDebugger >> actOnBrowserClosing: ann [

	self session ifNotNil: [:aSession|  aSession terminate ]
]

{ #category : #callbacks }
ACGlamourDebugger >> actOnReceiverUpdate [

	self 
		updateStack;
		updateReceiver


]

{ #category : #callbacks }
ACGlamourDebugger >> actOnSenderUpdate [

	self 
		updateSender


]

{ #category : #'building actions' }
ACGlamourDebugger >> addChangeDebuggerActionFor: aPresentation to: aCollection [
	
	(self debuggersForContext: self selectedContext)
		do: [ :aDebuggerClass | 
			aCollection
				add:
					(GLMGenericAction new
						action: [ self debug: self selectedContext using: aDebuggerClass ];
						title: aDebuggerClass defaultTitle;
						category: 'Available Debuggers';
						yourself) ]
]

{ #category : #building }
ACGlamourDebugger >> announcerIn: composite [

	composite dynamic
		display: [ :each | 
			GTInspector new first
				fixedSizePanes: 1; "Only one"
				noTitle;
				noActions;
				showFirst: [ :a | a custom: (ACDAnnouncerBrowser new debugger: self; startOn: each) ];
				startOn: each ]

]

{ #category : #accessing }
ACGlamourDebugger >> browser [ 

	^ self presentations first
]

{ #category : #building }
ACGlamourDebugger >> compose [

	self title: self debuggerTitle.
	self tabulator with: [:browser | 
		browser
			column: [ :column | 
						column
							row: #receiver;
							row: #announcer;
							row: #sender];
			column: #stack.
		
		browser transmit
			to: #receiver;
			transformed: [:session | session receiverContext];
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
			andShow: [ :composite | self stackIn: composite ].
		
		browser transmit
			from: #sender port: #entity;
			to: #sender port: #selectionInterval;
			when: [:senderContext | senderContext notNil ];
			transformed: [:senderContext | self session pcRangeForContext: senderContext].
		browser transmit
			from: #receiver port: #entity;
			to: #receiver port: #selectionInterval;
			when: [:receiverContext | receiverContext notNil ];
			transformed: [:receiverContext | self session pcRangeForContext: receiverContext] ].
		
	self on: GLMBrowserClosing send: #actOnBrowserClosing: to: self.
	self on: ACDReceiverUpdate send: #actOnReceiverUpdate to: self.
	self on: ACDSenderUpdate send: #actOnSenderUpdate to: self.
	self on: ACDAnnouncerUpdate send: #actOnAnnouncerUpdate to: self.
]

{ #category : #actions }
ACGlamourDebugger >> debug: aContext using: aDebuggerClass [
	| currentSession  |
	
	currentSession := self session.
	self detachSession.
	self browser close.
	currentSession updateContextTo: aContext.
	aDebuggerClass debugBasedOnSession: currentSession
]

{ #category : #accessing }
ACGlamourDebugger >> debuggerTitle [

	^ self class defaultTitle 
]

{ #category : #accessing }
ACGlamourDebugger >> debuggersForContext: aContext [

	"Ungly check to make sure the debugger will work until everything is in the image"
	(Smalltalk tools respondsTo: #debuggersForContext:excluding:) 
		ifTrue: [ ^ (Smalltalk tools debuggersForContext: aContext excluding: self class)]
		ifFalse: [ ^ OrderedCollection new ]
]

{ #category : #actions }
ACGlamourDebugger >> detachSession [

	(self browser pane port: #entity) silentValue: nil
]

{ #category : #initialization }
ACGlamourDebugger >> errorWasInUIProcess: aBoolean [

	self session errorWasInUIProcess: aBoolean
]

{ #category : #'building actions' }
ACGlamourDebugger >> installStackActionsFor: aPresentation [

	self installStackDynamicActionsFor: aPresentation.
]

{ #category : #'building actions' }
ACGlamourDebugger >> installStackDynamicActionsFor: aPresentation [
	
	aPresentation dynamicActionsOnSelection: [ :presentation || newActions |
		newActions := OrderedCollection new.
		self addChangeDebuggerActionFor: aPresentation to: newActions.
		newActions ]
]

{ #category : #opening }
ACGlamourDebugger >> openFullNoSuspendLabel: aString [
	"TODO: do not ignore the title"
	
	self open.
	"TODO: why is this necessy here? I took it from the current debugger"
	"errorWasInUIProcess := UIManager default spawnNewProcessIfThisIsUI: interruptedProcess"
	
]

{ #category : #initialization }
ACGlamourDebugger >> process: aProcess controller: aController context: aContext [

	self session: (self class spanCompleteSessionForContext: aContext fromProcess: aProcess)
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

{ #category : #actions }
ACGlamourDebugger >> resume [

	self session resume.
	self session clear.
	self browser close
]

{ #category : #accessing }
ACGlamourDebugger >> selectedContext [

	^ ((self browser paneNamed: #stack) port: #selection) value
]

{ #category : #building }
ACGlamourDebugger >> senderIn: composite [

	composite custom: (ACDSenderBrowser new debugger: self)

	"composite smalltalkCode
		title: [:senderContext | GTInspector new printObjectAsAnItem: senderContext receiver ];
		doItReceiver: [:senderContext | senderContext receiver ];
		format: [:senderContext |  senderContext  sourceCode asText makeSelectorBold];
		smalltalkClass: [ :senderContext | senderContext methodClass ];
		with: [ :code | self installCodeActionsFor: code ]
"
	"composite custom: ACDSenderBrowser new first noActions; noTitle "
]

{ #category : #accessing }
ACGlamourDebugger >> session [

	^ (self browser pane port: #entity) value
]

{ #category : #accessing }
ACGlamourDebugger >> session: aSession [

	 (self browser pane port: #entity) value: aSession
]

{ #category : #building }
ACGlamourDebugger >> stackIn: composite [

	composite list	
		title: 'Stack';
		showOnly: 50;
		display: #stack;
		format: [ :each | String streamContents: [:stream | each printDebugOn: stream ] ];
		selectionAct: [:each|  each selection explore] on: $i entitled: 'Explore';
		with: [ :list | self installStackActionsFor: list ]
]

{ #category : #updating }
ACGlamourDebugger >> updateAnnouncer [

	(self browser paneNamed: #announcer) update

]

{ #category : #updating }
ACGlamourDebugger >> updateReceiver [
	| receiverPane |
	receiverPane := self browser paneNamed: #receiver.
	(receiverPane port: #entity)
		value: nil;
		value: self session context.
	receiverPane update.
]

{ #category : #updating }
ACGlamourDebugger >> updateSender [
	| senderPane |
	senderPane := self browser paneNamed: #sender.
	(senderPane port: #entity)
		value: nil;
		value: self session senderContext .
	senderPane update.
]

{ #category : #updating }
ACGlamourDebugger >> updateStack [

	(self browser paneNamed: #stack) update
	
]

{ #category : #callbacks }
ACGlamourDebugger >> windowIsClosing [ 

	self announce: GLMBrowserClosing new
]
