---
title: "Git: push to other remote branch"
date: 2014-09-19 09:07 UTC
tags: git heroku
---

When deploying the app to Heroku it expects that we push it to the master branch on Heroku.

READMORE

This can be done like so:

```bash
$ git push heroku master
```

But what if we are working on another branch and want to test this e.g. on a staging environement on Heroku?

Pushing like before does not help. Even if we are currently on the branch we want to push git will take the same branch name and push this. So it will push the local `master` branch to `master` on Heroku.  
This is *not* what we want.

Instead we need to write something like this:

```bash
$ git push heroku other_branch:master
```

This will now take the `other_branch` we are working on and push this to `master`. Was a bit confusing for me at first but this is how it works.