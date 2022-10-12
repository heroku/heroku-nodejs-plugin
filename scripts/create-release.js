const { Octokit } = require("@octokit/rest");
const { assign } = Object;
const { GITHUB_TOKEN, GITHUB_TAG } = process.env;

let octokit = new Octokit({
  auth: GITHUB_TOKEN,
});

(async function() {
  await octokit.repos.createRelease({
    owner: 'heroku',
    repo: 'heroku-nodejs-plugin',
    tag_name: GITHUB_TAG,
    name: GITHUB_TAG,
    body: GITHUB_TAG,
  });
})();

