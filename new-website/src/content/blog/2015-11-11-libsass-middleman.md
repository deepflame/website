---
title: Using libSass in Middleman
date: 2015-11-11
tags: ["blog", "middleman", "sass", "ruby"]
---

After my long evening trying to upload the last blog post I wanted to make the livereload experience a bit better and tried to integrate libSass into Middleman.
Here is how.

READMORE

Digging into the Middleman gem I found that the 'main' gem is just a package of other gems. Running `bundle viz` I got the following image:

<% link_to "2015-11-11-libsass-middleman/gem_graph.svg", target: '_blank' do %>
  <%= image_tag '2015-11-11-libsass-middleman/gem_graph.svg' %>
<% end %>
(click to enlarge)

The same can be seen in the source code. It [only requires middleman-core](https://github.com/middleman/middleman/blob/v3-stable/middleman/lib/middleman.rb) and [includes a bunch of gems in the spec file](https://github.com/middleman/middleman/blob/v3-stable/middleman/middleman.gemspec):

```ruby
s.add_dependency("middleman-core", Middleman::VERSION)
s.add_dependency("middleman-sprockets", ">= 3.1.2")
s.add_dependency("haml", [">= 4.0.5"])
s.add_dependency("sass", [">= 3.4.0", "< 4.0"])
s.add_dependency("compass-import-once", ["1.0.5"])
s.add_dependency("compass", [">= 1.0.0", "< 2.0.0"])
s.add_dependency("uglifier", ["~> 2.5"])
s.add_dependency("coffee-script", ["~> 2.2"])
s.add_dependency("execjs", ["~> 2.0"])
s.add_dependency("kramdown", ["~> 1.2"])
```

Most of these gems I do not use. Today I would not write Coffeescript any more but only ES2015, not use Compass but libSass with mixins, not Haml but plain Html (for performance I guess), not use Kramdown but Redcarpet for Markdown parsing.

So I ripped out the stuff that I needed and changed my Gemfile from this:

```ruby
source 'https://rubygems.org'

gem "middleman", "~> 3.4"
```

to this:

```ruby
source 'https://rubygems.org'

gem "middleman-core", "~> 3.4"
gem "middleman-sprockets", ">= 3.1.2"
gem "uglifier", "~> 2.5"
gem "execjs", "~> 2.0"
gem "sass"
```

(just shown the middleman part)

Much better!

Now adding libSass was just replacing `sass` with the `sassc` gem and all seems to work fine!

Final result:

```ruby
source 'https://rubygems.org'

gem "middleman-core", "~> 3.4"
gem "middleman-sprockets", ">= 3.1.2"
gem "uglifier", "~> 2.5"
gem "execjs", "~> 2.0"
gem "sassc", "~> 1.8" # <- added libSass
```

Using and running Middleman did not change, just start it with `bundle exec middleman`.

Hope that helps.


**Update 2015-12-03**

The interesting thing is that `sassc` itself imports `sass`. So, how can we be sure that really `sassc` is used and not `sass`?

`Sassc` is faster than `sass` (that's why we are using it, right?). You will notice that especially for large projects.
You can also check this programmatically.

If we have `sass` included in our Gemfile we can compile a Sass string in the context of the bundle like this:

```
❯ bundle console
>> Sass.compile "body { color: red }"
=> "body {\n  color: red; }\n"
```

This does not work anymore if we have `sassc` installed. We need to use the SassC method.

```
❯ bundle console
>> Sass.compile "body { color: red }"
NoMethodError: undefined method `compile' for Sass:Module

>> SassC::Engine.new("body { color: red; }").render
=> "body {\n  color: red; }\n"
```

It also seems that `sassc` just uses `sass` to import some sass functions as you can see [on Github](https://github.com/sass/sassc-ruby/blob/master/lib/sassc/script.rb).