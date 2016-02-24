# Workers

Provides an abstraction over ActiveJob and the current implementation of choice (Sidekiq).

Add the line `include Workers::BackgroundJob` to each worker extending from `ActiveJob::Base` to
add common logging, resources and error handing.

This project rocks and uses MIT-LICENSE.

## Installation

Include the gem:

```
gem 'workers', path: 'engines/workers'
```

Run the generator:

```
rails g workers:initializer
```
