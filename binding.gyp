{
	"targets": [
		{
			"target_name": "event-loop-stats",
			"sources": [
				"src/eventLoopStats.cc"
			],
			"include_dirs" : [
				"<!(node -e \"require('nan')\")"
			]
		},
		{
			"target_name": "gc-stats",
			"sources": [
				"src/gcStats.cc"
			],
			"include_dirs" : [
				"<!(node -e \"require('nan')\")"
			]
		}
	]
}
