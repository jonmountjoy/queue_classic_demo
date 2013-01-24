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

## Authors

[Jon Mountjoy](https://github.com/jonmountjoy) & [Raul Murciano](https://github.com/raul)

## License

MIT