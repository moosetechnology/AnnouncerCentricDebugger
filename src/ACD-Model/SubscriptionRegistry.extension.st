Extension { #name : #SubscriptionRegistry }

{ #category : #'*acd-model' }
SubscriptionRegistry >> acdSubscriptions [
	|subsCopy|
	
	self protected: [ subsCopy := subscriptions as: OrderedCollection ].
	
	^ subsCopy
]
