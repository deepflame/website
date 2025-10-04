---

title: Clear Rails cache on deployment
date: 2019-08-27 08:55 UTC
tags: rails, caching, deployment, devops, heroku

---

When you use Rails view caching and change the html the caching does not know about it and you need to invalidate the cache manually. Here is how to do it before every deployment. READMORE

As described in the previous post you can run `Rails.cache.clear` in the Rails console to clear the cache. Unfortunately there is no way (yet) to do it from the command line.
We can add a rake task that will do this for us.

Add a file called `cache.rake` to your `lib/tasks/` folder with the following contents:

```ruby
namespace :cache do
  desc "Clearing Rails cache"
  task :clear do
    Rails.cache.clear
  end
end
```

Then we can execute `./bin/rake cache:clear` and clear the Rails cache from the command line.

Now we can execute this on every deploy on Heroku.
Modify the `Procfile` to migrate the database and clear the cache on every deploy.

```
release: rake db:migrate cache:clear
web: bundle exec puma -C config/puma.rb
```
