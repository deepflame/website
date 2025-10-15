---
title: Import Heroku Postgres backup locally
date: 2014-12-28
update: 2015-11-11
tags: ["postgresql", "heroku"]
---

Some days ago I accidentally dropped my development database and lost all test data. Not having any seed files I just dumped the production data from Heroku and imported it locally.
Here is how.

READMORE

Well, this post is nothing new. This is mainly copied from the Heroku [documentation](https://devcenter.heroku.com/articles/heroku-postgres-import-export).
This post serves mostly as reference for me but I hope you also find it helpful.

Dump a backup

```shell
heroku pg:backups capture
curl -o latest.dump `heroku pg:backups public-url`
```

Restore locally

```shell
# choose:

# found on Stackoverflow (tested and worked)
pg_restore -O -d mydb latest.dump

# from Heroku docs
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U myuser -d mydb latest.dump
```

> This will usually generate some warnings, due to differences between your Heroku database and a local database, but they are generally safe to ignore.

Enjoy!