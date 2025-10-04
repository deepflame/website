---

title: Fix rendering issues by flushing Rails' cache
date: 2019-08-21 19:46 UTC
tags: rails, caching

---

When you use Rails caching to optimize your view layer in production you might run into rendering issues. "What, I thought I changed this HTML and it worked for me in development!"
Flushing the cache might be a brutal but effective solution. READMORE

You may know the phrase. "There are only two hard things in Computer Science: cache invalidation and naming things." by Phil Karlton. Well, if you have rendering issues on production you may just fix them by flushing the whole cache.
Running

```ruby
Rails.cache.clear
```

in the Rails console worked wonders.

However if it takes too long for you cache to warm up you better resort to more directed solutions :)
