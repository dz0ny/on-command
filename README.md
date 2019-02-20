# GitHub action to run arbitrary command from comments

This is much like https://github.com/actions/bin/tree/master/filter#filters-for-github-actions but for comments.

So for example if comment contains:

```markdown
Run action `/update my_cluster all-the-shops`
```

![Example](https://user-images.githubusercontent.com/239513/53124245-2aed4680-355b-11e9-979d-c68068564389.png)

and your action looks like:

```hcl
action "On update command" {
  uses = "dz0ny/on-command@master"
  args = "update"
}
```

The action will proceed with workflow and create file with comment arguments that further action can use.

```shell
cat $GITHUB_WORKSPACE/.github/update-args
cluster all-the-shops
```

## Limitations

Due to current [limitations of GitHub Actions](https://developer.github.com/actions/):

> GitHub Actions is limited to private repositories and push events in public repositories during the limited public beta.

*On-Command* action currently only works on private repositories since it requires `IssueCommentEvent` event.

## Example updating deployment on specific Kubernetes cluster

To configure the action simply add the following lines to your `.github/main.workflow` workflow file:

```hcl
[workflow "Automatic Cluster Update" {
  on = "issue_comment"
  resolves = "Deploy to GKE"
}

action "On update command" {
  uses = "dz0ny/on-command@master"
  args = "update"
}

action "Setup Google Cloud" {
  needs = ["On update command"]
  uses = "actions/gcloud/auth@master"
  secrets = ["GCLOUD_AUTH"]
}

action "Load GKE kube credentials" {
  needs = ["Setup Google Cloud"]
  uses = "actions/gcloud/cli@master"
  env = {
    PROJECT_ID = "fifth-byte-211221"
  }
  runs = "sh -l -c"
  args = ["CLUSTER=$(cat $GITHUB_WORKSPACE/.github/update-args | cut -d' ' -f1) && container clusters get-credentials $CLUSTER --zone us-central1-a --project $PROJECT_ID"]
}

action "Deploy to GKE" {
  needs = ["Load GKE kube credentials"]
  uses = "docker://gcr.io/cloud-builders/kubectl"
  env = {
    PROJECT_ID = "fifth-byte-211221"
  }
  runs = "sh -l -c"
  args = ["APPLICATION_NAME=$(cat $GITHUB_WORKSPACE/.github/update-args | cut -d' ' -f2) && cat $GITHUB_WORKSPACE/config.yml | sed 's/APPLICATION_NAME/'\"$APPLICATION_NAME\"'/' | kubectl apply -f - "]
}

```
