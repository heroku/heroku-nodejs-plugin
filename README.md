# heroku-nodejs-plugin

[![CircleCI](https://circleci.com/gh/heroku/heroku-nodejs-plugin/tree/main.svg?style=svg)](https://circleci.com/gh/heroku/heroku-nodejs-plugin)

A metrics plugin to add [Heroku runtime metrics](https://devcenter.heroku.com/articles/language-runtime-metrics)
to an existing Node.js application. The plugin is added to a [vendor directory](https://github.com/heroku/heroku-buildpack-nodejs/tree/main/plugin) in https://github.com/heroku/heroku-buildpack-nodejs.

# How does it work?

You can see most of the implementation details in `src/nativeStats.cc`. The plugin sets callbacks
around GC invocations, and during the `prepare` and `check` phases of the event loop, tracks the
amount of time spent in each.

This data is exposed to a JS loop that periodically sends data to Heroku's metrics service.

## Debugging

If the plugin is not working for you once you have enabled the feature on Heroku, the first thing
you should do is set the ENV var `NODE_DEBUG` to `heroku`. By default all logging from the plugin
is silenced.

```
$ heroku config:set NODE_DEBUG=heroku -a $APP_NAME
```

## Metrics collected

```json
{
  "counters": {
    "node.gc.collections": 748,
    "node.gc.pause.ns": 92179835,
    "node.gc.old.collections": 2,
    "node.gc.old.pause.ns": 671054,
    "node.gc.young.collections": 746,
    "node.gc.young.pause.ns": 91508781
  },
  "gauges": {
    "node.eventloop.usage.percent": 0.12,
    "node.eventloop.delay.ms.median": 5,
    "node.eventloop.delay.ms.p95": 100,
    "node.eventloop.delay.ms.p99": 100,
    "node.eventloop.delay.ms.max": 100
  }
}
```

## Development

You can collect and print out metrics locally by running the included Go server:

```
$ PORT=5001 go run fake_metrics_server.go
```

You can run develop this locally by running build:

```
$ npm run build
```

and including the built module in another local Node app like:

```
$ NODE_OPTIONS="--require {{ working directory }}/heroku-nodejs-plugin/heroku-nodejs-plugin" HEROKU_METRICS_URL="http://localhost:5001" node src/index.js
```

Example app with periodic event loop and gc activity: https://github.com/heroku/node-metrics-single-process

## Publishing new versions

New versions can be published to Github releases by merging all changes to `main` and running `scripts/publish.sh`
