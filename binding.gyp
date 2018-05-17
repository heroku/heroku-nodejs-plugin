{
	"targets": [
		{
			"target_name": "native-stats",
			"sources": [
				"src/nativeStats.cc"
			],
			"include_dirs": [
				"<!(node -e \"require('nan')\")"
			]
		}
	]
}
