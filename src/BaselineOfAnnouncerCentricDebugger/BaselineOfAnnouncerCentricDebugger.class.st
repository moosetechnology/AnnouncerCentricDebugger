Class {
	#name : #BaselineOfAnnouncerCentricDebugger,
	#superclass : #BaselineOf,
	#category : #BaselineOfAnnouncerCentricDebugger
}

{ #category : #baselines }
BaselineOfAnnouncerCentricDebugger >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			spec
				baseline: 'GTDebugger' with: [ 
					spec repository: 'github://moosetechnology/gt-v1:pharo6/src' ].
			spec
				package: 'ACD-Model' with: [ spec requires: #('GTDebugger') ];
				package: 'ACD-Glamour-Interface' with: [ spec requires: #('ACD-Model') ];
				package: 'GT-DebuggerExtensions' with: [ 
					spec
						repository: 'github://moosetechnology/gt-v1:pharo6/src'; 
						requires: #('GTDebugger') ] ]
]
