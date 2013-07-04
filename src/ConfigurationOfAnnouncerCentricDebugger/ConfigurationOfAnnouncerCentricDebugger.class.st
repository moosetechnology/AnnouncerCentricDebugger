"
ConfigurationOfAnnouncerCentricDebugger loadDevelopment
"
Class {
	#name : #ConfigurationOfAnnouncerCentricDebugger,
	#superclass : #Object,
	#instVars : [
		'project'
	],
	#category : #ConfigurationOfAnnouncerCentricDebugger
}

{ #category : #private }
ConfigurationOfAnnouncerCentricDebugger class >> ensureMetacello [
        "Bootstrap Gofer (if necessary), load latest mcz file for ConfigurationOfMetacello (using old 
         Gofer API), then load the latest version of Metacello itself."

        Smalltalk at: #MetacelloProject ifAbsent: [ | error |
                "list of repositories to try, in case primary repository is not accessible"
                (Array 
                        with: 'http://www.squeaksource.com/MetacelloRepository' 
                        with: 'http://seaside.gemstone.com/ss/metacello') do: [:repositoryUrl |
                                ([
                                        Smalltalk at: #Gofer ifAbsent: [
                                        "Current version of Gofer from which to bootstrap - as of 1.0-beta.21"
                                                self bootstrapPackage: 'Gofer-Core-lr.115' from: repositoryUrl ].
                                        Smalltalk at: #Gofer ifPresent: [:goferClass | | gofer |
                                                gofer := goferClass new
                                                        url: repositoryUrl;
                                                        yourself.
                                                [ gofer addPackage: 'ConfigurationOfMetacello' ] on: Warning do: [:ex | ex resume ].
                                                gofer load ]]
                                                        on: Error
                                                        do: [ :ex |
                                                                error := ex.
                                                                Transcript 
                                                                        cr; 
                                                                        show: 'failed ensureMetacello: ';
                                                                        show: ex description printString;
                                                                        show: '...retrying'.
                                                                "try again"
                                                                ex return: nil ]) ~~ nil
                                        ifTrue: [
                                                "load 'default' group of Metacello"
                                                (Smalltalk at: #ConfigurationOfMetacello) perform: #load.
                                                ^self ]].
                "shouldn't get here unless the load failed ... throw an error"
                self error: 'retry with alternate repository failed: ', error description printString ]
]

{ #category : #'metacello tool support' }
ConfigurationOfAnnouncerCentricDebugger class >> isMetacelloConfig [
	"Answer true and the Metacello tools will operate on you"
	
	^true
]

{ #category : #loading }
ConfigurationOfAnnouncerCentricDebugger class >> loadDefault [
	self loadDevelopment
]

{ #category : #loading }
ConfigurationOfAnnouncerCentricDebugger class >> loadDevelopment [
	(self project version: #development) load
]

{ #category : #accessing }
ConfigurationOfAnnouncerCentricDebugger class >> project [

	^self new project
]

{ #category : #baselines }
ConfigurationOfAnnouncerCentricDebugger >> baseline01: spec [ 
	<version: '0.1-baseline'>
	
	spec for: #common do: [
		spec blessing: #baseline.
		spec repository: 'http://www.smalltalkhub.com/mc/AndreiChis/AnnouncerCentricDebugger/main'.
		spec 
			package: 'ACD-Model' with: [spec requires: #('NewDebugger-Core')];
			package: 'ACD-Glamour-Interface' with: [spec requires: #('Core' 'DebuggerExtensions')].

		spec group: 'default' with: #(
			'Core'
			'UI' ).
		spec group: 'Core' with: #(
			'ACD-Model' ).
		spec group: 'UI' with: #(
			'ACD-Glamour-Interface' ).
			
		spec project: 'NewDebugger-Core' with: [
				spec
					className: 'ConfigurationOfNewDebugger';
					file: 'ConfigurationOfNewDebugger';
					version: #stable;
					loads: 'Core';
					repository: 'http://www.smalltalkhub.com/mc/Pharo/Debugger/main' ].
		spec package: 'DebuggerExtensions' with: [ spec repository: 'http://www.smalltalkhub.com/mc/AndreiChis/Playground/main' ]
	]
]

{ #category : #baselines }
ConfigurationOfAnnouncerCentricDebugger >> development: spec [
	<symbolicVersion: #'development'>

	spec for: #'common' version: '0.1-baseline'
]

{ #category : #accessing }
ConfigurationOfAnnouncerCentricDebugger >> project [

	^ project ifNil: [ | constructor |
		"Bootstrap Metacello if it is not already loaded"
		self class ensureMetacello.
		"Construct Metacello project"
		constructor := (Smalltalk at: #MetacelloVersionConstructor) on: self.
		project := constructor project.
		project]
]