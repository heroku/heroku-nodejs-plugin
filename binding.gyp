{
	"targets": [
		{
			"target_name": "native-stats",
			"sources": [
				"src/nativeStats.cc"
			],
			"include_dirs": ["<!@(node -p \"require('node-addon-api').include\")"],
			"dependencies": ["<!(node -p \"require('node-addon-api').gyp\")"],
			"defines": ["NAPI_DISABLE_CPP_EXCEPTIONS"],
		}
	]
}
