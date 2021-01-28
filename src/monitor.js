const http = require('http');
const https = require('https');
const url = require('url');
const util = require('util');
const { Histogram } = require("measured-core");
const nativeStats = require('./nativeStats');

// url is where the runtime metrics will be posted to. This is added
// to dynos by runtime iff the app is opped into the heroku runtime metrics
// beta.
let uri = url.parse(process.env.HEROKU_METRICS_URL);

function submitData(data, cb) {
  const postData = JSON.stringify(data);

  // post data to metricsURL
  const options = {
    method: "POST",
    protocol: uri.protocol,
    hostname: uri.hostname,
    port: uri.port,
    path: uri.path,
    headers: {
      "Content-Type": "application/json",
      "Content-Length": Buffer.byteLength(postData),
    },
  };

  const request = uri.protocol === 'https:' ? https.request : http.request;
  const req = request(options, res => cb(null, res));
  req.on('error', cb);
  req.write(postData);
  req.end();
}

function start() {
  const log = util.debuglog('heroku');

  const METRICS_INTERVAL = parseInt(process.env.METRICS_INTERVAL_OVERRIDE, 10) || 20000; // 20 seconds

  // Set a minimum of 10 seconds
  if (METRICS_INTERVAL < 10000) {
    METRICS_INTERVAL = 10000;
  }

  // Collects the event loop ticks, and calculates p50, p95, p99, max
  let delay = new Histogram();

  nativeStats.start();

  // every METRICS_INTERVAL seconds, submit a metrics payload to metricsURL.
  setInterval(() => {
    let { ticks, gcCount, gcTime, oldGcCount, oldGcTime, youngGcCount, youngGcTime } = nativeStats.sense();
    let totalEventLoopTime = ticks.reduce((a, b) => a + b, 0);

    ticks.forEach(tick => delay.update(tick));

    let aa = totalEventLoopTime / METRICS_INTERVAL;

    let { median, p95, p99, max } = delay.toJSON();

    let data = {
      counters: {
        "node.gc.collections": gcCount,
        "node.gc.pause.ns": gcTime,
        "node.gc.old.collections": oldGcCount,
        "node.gc.old.pause.ns": oldGcTime,
        "node.gc.young.collections": youngGcCount,
        "node.gc.young.pause.ns": youngGcTime,
      },
      gauges: {
        "node.eventloop.usage.percent": aa,
        "node.eventloop.delay.ms.median": median,
        "node.eventloop.delay.ms.p95": p95,
        "node.eventloop.delay.ms.p99": p99,
        "node.eventloop.delay.ms.max": max
      }
    };

    submitData(data, (err, res) => {
      if (err !== null) {
        log(
          "[heroku-nodejs-plugin] error when trying to submit data: ",
          err
        );
        return;
      }

      if (res.statusCode !== 200) {
        log(
          "[heroku-nodejs-plugin] expected 200 when trying to submit data, got:",
          res.statusCode
        );
        return;
      }
    });

    delay.reset();
  }, METRICS_INTERVAL).unref();
}

module.exports = start;