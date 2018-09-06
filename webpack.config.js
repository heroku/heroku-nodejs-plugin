let webpack = require('webpack');
let path = require('path');

let match = process.version.match(/^v([0-9]+)/);

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
    },
    plugins: [
        new webpack.DefinePlugin({
            // Save the major version of Node that the plugin was compiled with
            // so that the plugin can perform a no-op when included in a different
            // version of Node
            NODE_MAJOR_VERSION: `"${match[1]}"`,
        }),
    ]
};
