const archiveName = process.argv[2];
const archiveShaName = process.argv[3];

const { Octokit } = require("@octokit/rest");
const { assign } = Object;
const { GITHUB_TOKEN, CIRCLE_TAG } = process.env;

let octokit = new Octokit({
  auth: GITHUB_TOKEN,
});

(async function() {
  const {
    data: {
      upload_url
    }
  } = await octokit.repos.createRelease({
    owner: 'heroku',
    repo: 'heroku-nodejs-plugin',
    tag_name: CIRCLE_TAG,
    name: CIRCLE_TAG,
    body: CIRCLE_TAG,
  });

  let uploadParams = {
    method: 'POST',
    url: upload_url,
    headers: {
      "Content-Type": "application/zip"
    },
  };

  await Promise.all([
    octokit.request(assign(uploadParams, {
      data: archiveName,
      name: archiveName
    })),
    octokit.request(assign(uploadParams, {
      data: archiveShaName,
      name: archiveShaName
    }))
  ]);
})();

