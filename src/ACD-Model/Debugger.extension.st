Extension { #name : #Debugger }

{ #category : #'*acd-model' }
Debugger >> untilClientInvokesAnnouncer [
	self selectedContext receiver haltWhenClientInvokesAnnouncer .
	self proceed.
]
