# Queue Classic Demo

A sample Rails application that combines:
* [queue_classic](https://github.com/ryandotsmith/queue_classic) for queueing background jobs,
* a Redis store for determining job status and holding processed jobs
* a polling-Ajaxy submission form for submitting the jobs and waiting for the results
* rendering the results via ERB (and storing that rendered HTML in the Redis store)

## Local requirements

* Install and run a Postgresql server
* Install and run a Redis server
* Install the [Heroku Toolbelt](https://toolbelt.heroku.com)

## Setup

* Execute `createdb queue_classic_demo_development` - we'll configure queue_classic to use it
* Execute `foreman run rake db:migrate` - runs the migration to set up the database for queue_classic
* Create a `.env` file, something like this, which holds config vars for all our dependencies:

```
RAILS_ENV=development
DATABASE_URL=postgres://localhost/queue_classic_demo_development
REDISTOGO_URL=redis://localhost:6379
```

## Running

* Start the server: `foreman start web` - you'll now be able to add a job via the web UI.  This takes the input, submits it, and loops, polling periodically for a result
* Start the worker: `foreman start worker` - this will grab a job, process & render it

## Deploying and running on Heroku

* `heroku create` - create a new app on Heroku
* `git push heroku master` - deploy (as this is a Rails app.  It will get a [starter-tier database](https://devcenter.heroku.com/articles/heroku-postgres-plans#starter-tier) provisioned [by default](https://devcenter.heroku.com/articles/ruby-support#addons))
* `heroku addons:add redistogo:nano` - provision a Redis store via the [Redis To Go](https://devcenter.heroku.com/articles/redistogo) Heroku add-on
* `heroku run rake db:migrate` - initialise the database

That's it!

* `heroku open` will open your browser on your running application.
* Submit a job by typing in some text and hitting Send
* In another terminal, scale the workers so you have a few that can process the job:  `heroku scale worker=1`
* `heroku logs` to see what's going on

## How it works

There aren't too many moving parts.  Checking out the `Procfile` you'll see two main components: the web front end, and the worker.

The big picture is:
* The web front end lets you create a job.
* Job creation involves assigning an ID to the job, and enqueuing it.
* The web front end then polls periodically, waiting for the result.
* The worker process takes jobs off the queue, processes them, and stores the result.

### Web

Check out `new.html.erb`, rendered via `new` on `FrontController`.  It's pretty much just a simple form that submits to FrontController's create method.  However, it also contains some magic JavaScript:
* This ensure that the form calls `sendJobForm` instead of just submitting as usual
* Which, in turn, disables the submission button (preventing multiple submission)
* Performs a POST to the `create` URL on the FrontController controller. 
* The controller queues up the job, and returns an ID for it.
* Which is then used in the call to `pollJob`
* `pollJob`, every 2 seconds, does a GET on the FrontController's `fetch` using the ID.  This generally returns one of two values: a 202 (job isn't complete yet), in which case `pollJob` sets a timer to have `poll` called again.  The other value is 200, indicating that the enqueued job has been processed, and that `data` contains the resuling HTML. `jobFinished` is called in this case, which releases the submit button, and displays the HTML.
* Check out the `fetch` and `create` methods to see how the different status codes are returned.

### Jobs

The `Job` class does the grunt work.  `enqueue` increments a counter that represents the ID of the job (Redis will default the counter value to zero on first call if it doesn't exist), enqueues the work on queue_classic, and returns the counter.  

The other methods simply set/get the results, and provides a check to see if a result is available.

## Worker

A worker is created via the `work.rake` which simply instantiates a new instance of `DemoWorker`.  The `work` method is the only one that matters here - it processes the incoming work, renders HTML via ERB, and stores it using `Job.setResult`.  

This ensures that the `fetch` method on the controller will see that the job has completed, and the value will be returned.


## Authors

[Jon Mountjoy](https://github.com/jonmountjoy) & [Raul Murciano](https://github.com/raul)

## License

MIT