# node-metrics-plugin

A metrics plugin to add Heroku runtime metrics to an existing Node.js application.

## Usage

See: https://github.com/heroku/heroku-nodejs-metrics-buildpack for more details

## Metrics collected

```json
{
  "counters": {
    "node.gc.collections": 0,
    "node.gc.pause.ns": 0
  },
  "gauges": {
    "node.heap.inuse.bytes": 12472640,
    "node.heap.total.bytes": 17158144,
    "node.heap.limit.bytes": 1501560832
  }
}
```
