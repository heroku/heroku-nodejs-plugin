const util = require('util');
const log = util.debuglog('heroku');

// if the node version does not match the major version, bail
const match = process.version.match(/^v([0-9]+)/);
const isExpectedNodeVersion = match && match[1] === NODE_MAJOR_VERSION;

// if we are not using node installed by the Heroku buildpack, bail
const isExpectedNodePath = process.execPath === "/app/.heroku/node/bin/node";

if (isExpectedNodeVersion && isExpectedNodePath) {
  const start = require('./monitor.js');
  start();
} else {
  if (!isExpectedNodePath) {
    log("[heroku-nodejs-plugin] expected different Node path. Found:", process.execPath);
  }
  if (!isExpectedNodeVersion) {
    log("[heroku-nodejs-plugin] expected different Node version. Expected:",
    NODE_MAJOR_VERSION,
    "Found:",
    match && match[1]);
  }
}
