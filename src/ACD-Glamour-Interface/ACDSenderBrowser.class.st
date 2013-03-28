Class {
	#name : #ACDSenderBrowser,
	#superclass : #GLMCompositePresentation,
	#instVars : [
		'debugger'
	],
	#category : #'ACD-Glamour-Interface'
}

{ #category : #building }
ACDSenderBrowser >> compose [

	self smalltalkCode
		title: [:senderContext | GTInspector new printObjectAsAnItem: senderContext receiver ];
		doItReceiver: [:senderContext | senderContext receiver ];
		format: [:senderContext |  senderContext  sourceCode asText makeSelectorBold];
		smalltalkClass: [ :senderContext | senderContext methodClass ];
		with: [ :code | self installActionsFor: code ]
]

{ #category : #accessing }
ACDSenderBrowser >> debugger [

	^ debugger 
]

{ #category : #accessing }
ACDSenderBrowser >> debugger: anObject [

	debugger := anObject 
]

{ #category : #building }
ACDSenderBrowser >> installActionsFor: aPresentation [

	self installWhereIsActionFor: aPresentation.
]

{ #category : #building }
ACDSenderBrowser >> installWhereIsActionFor: aPresentation [ 

	aPresentation 
		act: [ :textPresentation :context | 
			textPresentation selectionInterval: (self session pcRangeForContext:  context) ]
		icon: GLMUIThemeExtraIcons glamorousSearch 
		on: $w
		entitled: 'Where is?'
]

{ #category : #accessing }
ACDSenderBrowser >> session [

	^ self debugger session 
]
