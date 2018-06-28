let webpack = require('webpack');
let path = require('path');

module.exports = {
    // Don't minify the output script
    mode: 'none',

    // Don't polyfill native node libraries for the browser
    target: 'node',

    output: {
        // output to the /heroku-nodejs-plugin instead of /dir
        path: path.resolve(__dirname, "heroku-nodejs-plugin"),

        // Make sure the output file is named `index.js`
        filename: 'index.js',
    }
};
