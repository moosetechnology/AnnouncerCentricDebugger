Extension { #name : #Object }

{ #category : #'*acd-model' }
Object >> haltWhenAnnoucerIsNotified [
	| aMetaObject |
	aMetaObject := ACDBehavioralMetaObject new.
	aMetaObject 
		whenAnnoucerIsNotifiedDo: [ :senderContext :announcerContext |
			self metaObject unbindFrom: self.  
			ACGlamourDebugger openOnSender: senderContext announcer: announcerContext ].
	aMetaObject bindTo: self 
]

{ #category : #'*acd-model' }
Object >> haltWhenAnnoucerIsNotifiedBy: anObject [
	| aMetaObject |
	aMetaObject := ACDBehavioralMetaObject new.
	aMetaObject 
		whenAnnoucerIsNotifiedDo: [ :senderContext :announcerContext |
			senderContext receiver == anObject ifTrue: [
				self metaObject unbindFrom: self.  
				ACGlamourDebugger openOnSender: senderContext announcer: announcerContext ] ].
	aMetaObject bindTo: self 
]

{ #category : #'*acd-model' }
Object >> haltWhenClientInvokesAnnouncer [
	| aMetaObject |
	aMetaObject := ACDBehavioralMetaObject new.
	aMetaObject 
		whenClientInvokesAnnouncerDo: [ :senderContext |
			self metaObject unbindFrom: self.
			ACGlamourDebugger openOnSender: senderContext ].
	aMetaObject bindTo: self 
]

{ #category : #'*acd-model' }
Object >> haltWhenClientReceivesAnnouncement [
	| aMetaObject |
	aMetaObject := ACDBehavioralMetaObject new.
	aMetaObject 
		whenObjectReceivesAnnouncementDo: [ :senderContext :announcerContext :receiverContext |
			self metaObject unbindFrom: self.  
			"GTDebugger debugCurrentProcess."
			ACGlamourDebugger openOnSender: senderContext announcer: announcerContext receiver: receiverContext ].
	aMetaObject bindTo: self 
]

{ #category : #'*acd-model' }
Object >> haltWhenClientReceivesAnnouncementAndConditionHolds: aCondition [
	| aMetaObject |
	aMetaObject := ACDBehavioralMetaObject new.
	aMetaObject 
		whenObjectReceivesAnnouncementDo: [ :senderContext :announcerContext :receiverContext |
			(aCondition copy
				senderContext: senderContext;
				announcerContext: announcerContext;
				receiverContext: receiverContext) check ifTrue: [ 
					self metaObject unbindFrom: self.  
					"GTDebugger debugCurrentProcess."
					ACGlamourDebugger openOnSender: senderContext announcer: announcerContext receiver: receiverContext ] ].
	aMetaObject bindTo: self 
]

{ #category : #'*acd-model' }
Object >> haltWhenObjectReceivesAnnouncementFromAnnouncer: anObject [
	
	self haltWhenClientReceivesAnnouncementAndConditionHolds: 
		(ACDReceiverCondition check: [ :senderContext :announcerContext | 
			announcerContext receiver == anObject ])
]

{ #category : #'*acd-model' }
Object >> haltWhenObjectReceivesAnnouncementFromSender: anObject [
	
	self haltWhenClientReceivesAnnouncementAndConditionHolds: 
		(ACDReceiverCondition check: [ :senderContext | 
			senderContext receiver == anObject ])
]

{ #category : #'*acd-model' }
Object >> haltWhenObjectReceivesAnnouncementFromSender: anObject1 andAnnouncer: anObject2 [
	
	self haltWhenClientReceivesAnnouncementAndConditionHolds: 
		(ACDReceiverCondition check: [ :senderContext :announcerContext | 
			senderContext receiver == anObject1 and: [announcerContext receiver == anObject2] ])
]
