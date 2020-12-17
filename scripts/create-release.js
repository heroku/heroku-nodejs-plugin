const { Octokit } = require("@octokit/rest");
const { assign } = Object;
const { GITHUB_TOKEN, CIRCLE_TAG } = process.env;

let octokit = new Octokit({
  auth: GITHUB_TOKEN,
});

(async function() {
  await octokit.repos.createRelease({
    owner: 'heroku',
    repo: 'heroku-nodejs-plugin',
    tag_name: CIRCLE_TAG,
    name: CIRCLE_TAG,
    body: CIRCLE_TAG,
  });
})();

