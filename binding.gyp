{
	"targets": [
		{
			"target_name": "heroku-nodejs-plugin",
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
			"dependencies": ["heroku-nodejs-plugin"],
			"copies": [
				{
					"files": ["./build/Release/heroku-nodejs-plugin.node"],
					"destination": "./heroku-nodejs-plugin/"
				}
			]
		}
	]
}
