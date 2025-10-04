---
title: Simple Countdown using Ember-concurrency
date: 2019-08-28
tags: ["emberjs", "ember-concurrency"]
---

Ever wanted to automatically advance progress in Ember like a slideshow, a countdown or... ? Here is how we can do it with ember-concurrency. READMORE

The idea is that we want to advance progress. Let us take the countdown example for simplicity.

The meat of the whole implementation is actually the task from [ember-concurrency](http://ember-concurrency.com) itself. It uses a generator function and looks like this:

```javascript
  countdownTask: task(function * () {
    while (! this.get('countdownFinished')) {
      this.decrementProperty('currentValue');
      yield timeout(1000);
    }
  }),
```

I assume the code is pretty straight forward. Until the countdown is finished decrement the current countdown value and wait for 1sec on every iteration.

We can start and stop the countdown with template helpers that [ember-concurrency](http://ember-concurrency.com) gives us:

```handlebars
{{#if this.countdownTask.isIdle}}
  <button onclick={{action (perform this.countdownTask)}}>
    Start
  </button>
{{else}}
  <button onclick={{action (cancel-all this.countdownTask)}}>
    Stop
  </button>
{{/if}}
```

So if the task is idle it shows the 'start' button, otherwise the 'stop' button. There are also other readonly properties on the task that we could use like `isRunning`.
Please refer to the documentation for more information.

You may check out the implementation in the Twiddle below or have a look directly at its [gist](https://gist.github.com/deepflame/7cfecd6b7dc80cede294e220adc626ff).
There are many more areas you may want to use tasks.

Have fun!


<div style="position: relative; height: 0px; overflow: hidden; max-width: 100%; padding-bottom: 56.25%;"><iframe src="https://ember-twiddle.com/7cfecd6b7dc80cede294e220adc626ff?fullScreen=true" style="position: absolute; top: 0px; left: 0px; width: 100%; height: 100%;"></iframe></div>