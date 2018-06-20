{
	"targets": [
		{
			"target_name": "heroku-nodejs-metrics-plugin",
			"sources": [
				"src/nativeStats.cc"
			],
			"include_dirs": [
				"<!(node -e \"require('nan')\")"
			],
		},
		{
			"target_name": "action_after_build",
			"type": "none",
			"dependencies": ["heroku-nodejs-metrics-plugin"],
			"copies": [
				{
					"files": ["./build/Release/heroku-nodejs-metrics-plugin.node"],
					"destination": "./dist/"
				}
			]
		}
	]
}
