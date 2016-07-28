Oathkeeper
---

**Oathkeeper**  is an ActiveRecord extension that logs audits of models.  The audits are stored in MongoDB as specified by the oathkeeper.yml file.
It is primarily meant to be used in conjuction with Rails.

Oathkeeper currently supports Rails 3.2, 4.1.x

Oathkeeper supports the following Ruby version:
* 2.2.x


## Supported ORMS
* ActiveRecord

## Installation

```ruby
  gem "oathkeeper"
```

## ActiveRecord Usage

include the `oathkeeper` module in your activerecord models:

```ruby
class User < ActiveRecord::Base
  oath_keeper
end
```

Whenever a user is created, updated or destroyed, a new audit is created and stored in mongo.

### Options

#### Ignoring fields

```ruby
class User < ActiveRecord::Base
  #audits all fields
  oath_keeper

  #ignore fields
  oath_keeper :ignore => [:login_count, :current_login_ip, :last_login_ip]
end
```

#### Meta fields

Sometimes when an audit event occurs it is helpful to include additional context to the audit event for auditing purposes.  Meta allows this.
When you specify meta options Oathkeeper looks for the model association and calls the defined method.  This information is stored in the meta field in the audit

```ruby
class VlabelMap < ActiveRecord::Base
  oath_keeper :meta => [[:group,:display_name],[:preroute_group,:group_name],[:geo_route_group,:name],[:survey_group,:name]]
end
```
This will produce the following in the meta field on an audit event

```ruby
```


#### Master Event
**rename**

Sometimes we don't care about an individual audit.  Instead when a change happens this will instead audit the event as a master_event based on the settings

```ruby
class TimeSegment < ActiveRecord::Base
  oath_keeper :master_event => {:type => Package, :finder=> Proc.new {|t| t.profile.package}}
end

  #A time_segment event instead becomes a package audit
```

#### Version
**beta**
Adding a version flag will store changes of the object in a separate mongo collection as means for restoration or auditing.

```ruby
class Package < ActiveRecord::Base
  oath_keeper meta: proc { |t| t.meta_data  }, version: true
end
```

## PORO Objects (plain old ruby objects)
There was an attempt to audit not activerecord objects.  It 'works' but it is very brittle.

**TODO**


## Audits

## Gotchas

## Contributing

### Testing

```ruby
bundle exec rspec spec
```
