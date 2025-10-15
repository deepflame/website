---
title: "Git: push subdirectory to Heroku"
date: 2014-12-30
tags: ["git", "heroku"]
published: true
---

Do you have a frontend app and the backend in the same Git repository and would like to deploy only the backend part to Heroku?
Well, we have and here is how to pushed only the backend to Heroku.

READMORE

Following is a part of our project directory structure. The backend is a Rails app and the frontend an EmberJS cli app.

```shell
➜  AwesomeProject git:(master) ✗ tree -d -L 2
.
├── backend
│   ├── app
│   ├── bin
│   ├── config
│   ├── db
│   ├── doc
│   ├── lib
│   ├── log
│   ├── public
│   ├── test
│   ├── tmp
│   └── vendor
└── frontend
    ├── app
    ├── bower_components
    ├── config
    ├── dist
    ├── node_modules
    ├── public
    ├── tests
    ├── tmp
    └── vendor

22 directories
```

So this is nothing too extraordinary. For the deployment we build the Ember app and put the assets into Rails' `public` folder. Then the whole app is pushed to Heroku.

To only push the backend part (with all the assets from Ember) we do the following:

```shell
git push $REMOTE_NAME `git subtree split --prefix backend`:master --force
```

This will forcefully push the backend folder in the current branch to the set `$REMOTE_NAME`.
I extracted this line from a script we use, so you may add your git remote name here.


If for some reason you want to try not to use the `--force` option you can simply write:

```shell
git subtree push --prefix backend $REMOTE_NAME master
```

Enjoy!