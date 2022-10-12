const archiveName = process.argv[2];
const archiveShaName = process.argv[3];

const fs = require("fs");
const { Octokit } = require("@octokit/rest");
const { assign } = Object;
const { GITHUB_TOKEN, GITHUB_TAG } = process.env;

let octokit = new Octokit({
  auth: GITHUB_TOKEN,
});

(async function() {
  const {
    data: {
      upload_url
    }
  } = await octokit.repos.getReleaseByTag({
    owner: 'heroku',
    repo: 'heroku-nodejs-plugin',
    tag: GITHUB_TAG,
  });

  let uploadParams = {
    method: 'POST',
    url: upload_url,
    headers: {
      "Content-Type": "application/zip"
    },
  };

  let archive = await fs.readFileSync(archiveName);
  let archiveSha = await fs.readFileSync(archiveShaName);

  await Promise.all([
    octokit.request(assign(uploadParams, {
      data: archive,
      name: archiveName
    })),
    octokit.request(assign(uploadParams, {
      data: archiveSha,
      name: archiveShaName
    }))
  ]);
})();

