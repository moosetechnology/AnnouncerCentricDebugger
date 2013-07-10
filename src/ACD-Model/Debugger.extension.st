Extension { #name : #Debugger }

{ #category : #'*ACD-Model' }
Debugger >> untilClientInvokesAnnouncer [
	self selectedContext receiver haltWhenClientInvokesAnnouncer .
	self proceed.
]
