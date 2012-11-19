# Draper: View Models for Rails

[![TravisCI Build Status](https://secure.travis-ci.org/drapergem/draper.png?branch=master)](http://travis-ci.org/drapergem/draper)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/drapergem/draper)

## Quick Start

1. Add `gem 'draper'` to your `Gemfile` and `bundle`
2. When you generate a resource with `rails g resource YourModel`, you get a decorator automatically!
3. If `YourModel` already exists, run `rails g decorator YourModel` to create `YourModelDecorator`
4. Edit `app/decorators/[your_model]_decorator.rb` using:
  1. `h` to proxy to Rails/application helpers like `h.current_user`
  2. the name of your decorated model to access the wrapped object like `article.created_at`
5. Wrap models in your controller with the decorator using:
  1. `.find` automatic lookup & wrap
    ex: `ArticleDecorator.find(1)`
  2. `.decorate` method with a single object or collection,
    ex: `ArticleDecorator.decorate(Article.all)`
  3. `.new` method with single object
    ex: `ArticleDecorator.new(Article.first)`
6. Call decorator methods from your view templates
  ex: `<%= @article_decorator.created_at %>`

If you need common methods in your decorators, create an `app/decorators/application_decorator.rb`:

``` ruby
class ApplicationDecorator < Draper::Base
  # your methods go here
end
```

and make your decorators inherit from it. Newly generated decorators will respect this choice and inherit from `ApplicationDecorator`.

## Goals

This gem makes it easy to apply the decorator pattern to domain models in a Rails application. This pattern gives you three wins:

1. Replace most helpers with an object-oriented approach
2. Filter data at the presentation level
3. Enforce an interface between your controllers and view templates.

### 1. Object Oriented Helpers

Why hate normal helpers? In Ruby/Rails we approach everything from an Object-Oriented perspective, then with helpers we get procedural.The job of a helper is to take in data and output a presentation-ready string. We can do that with a decorator.

A decorator wraps an object with presentation-related accessor methods. For instance, if you had an `Article` object, then the decorator could override `.published_at` to use formatted output like this:

```ruby
class ArticleDecorator < Draper::Base
  decorates :article

  def published_at
    date = h.content_tag(:span, article.published_at.strftime("%A, %B %e").squeeze(" "), :class => 'date')
    time = h.content_tag(:span, article.published_at.strftime("%l:%M%p"), :class => 'time').delete(" ")
    h.content_tag :span, date + time, :class => 'created_at'
  end
end
```

### 2. View-Layer Data Filtering

Have you ever written a `to_xml` or `to_json` method in your model? Did it feel weird to put presentation logic in your model?

Or, in the course of formatting this data, did you wish you could access `current_user` down in the model? Maybe for guests your `to_json` is only going to show three attributes, but if the user is an admin they get to see them all.

How would you handle this in the model layer? You'd probably pass the `current_user` or some role/flag down to `to_json`. That should still feel slimy.

When you use a decorator you have the power of a Ruby object but it's a part of the view layer. This is where your `to_json` belongs. You can access your `current_user` helper method using the `h` proxy available in the decorator:

```ruby
class ArticleDecorator < ApplicationDecorator
  decorates :article

  ADMIN_VISIBLE_ATTRIBUTES = [:title, :body, :author, :status]
  PUBLIC_VISIBLE_ATTRIBUTES = [:title, :body]

  def to_json
    attr_set = h.current_user.admin? ? ADMIN_VISIBLE_ATTRIBUTES : PUBLIC_VISIBLE_ATTRIBUTES
    article.to_json(:only => attr_set)
  end
end
```

### 3. Enforcing an Interface

Want to strictly control what methods are proxied to the original object? Use `denies` or `allows`.

#### Using `denies`

The `denies` method takes a blacklist approach. For instance:

```ruby
class ArticleDecorator < ApplicationDecorator
  decorates :article
  denies :title
end
```

Then, to test it:

```irb
 > ad = ArticleDecorator.find(1)
 => #<ArticleDecorator:0x000001020d7728 @model=#<Article id: 1, title: "Hello, World">>
 > ad.title
NoMethodError: undefined method `title' for #<ArticleDecorator:0x000001020d7728>
```

#### Using `allows`

A better approach is to define a whitelist using `allows`:

```ruby
class ArticleDecorator < ApplicationDecorator
  decorates :article
  allows :title, :description
end
```

```irb
> ad = ArticleDecorator.find(1)
=> #<ArticleDecorator:0x000001020d7728 @model=#<Article id: 1, title: "Hello, World">>
> ad.title
=> "Hello, World"
> ad.created_at
NoMethodError: undefined method `created_at' for #<ArticleDecorator:0x000001020d7728>
```

## Up and Running

### Setup

Add the dependency to your `Gemfile`:

```
gem "draper"
```

Then run `bundle` from the project directory.

### Generate the Decorator

To decorate a model named `Article`:

```
rails generate decorator article
```

### Writing Methods

Open the decorator model (ex: `app/decorators/article_decorator.rb`) and add normal instance methods. To access the wrapped source object, use a method named after the `decorates` argument:

```ruby
class ArticleDecorator < Draper::Base
  decorates :article

  def author_name
    article.author.first_name + " " + article.author.last_name
  end
end
```

### Using Existing Helpers

You probably want to make use of Rails helpers and those defined in your application. Use the `helpers` or `h` method proxy:

```ruby
class ArticleDecorator < Draper::Base
  decorates :article

  def published_at
    date = h.content_tag(:span, article.published_at.strftime("%A, %B %e").squeeze(" "), :class => 'date')
    time = h.content_tag(:span, article.published_at.strftime("%l:%M%p"), :class => 'time').delete(" ")
    h.content_tag :span, date + time, :class => 'created_at'
  end
end
```

#### Lazy Helpers

Hate seeing that `h.` proxy all over? Willing to mix a bazillion methods into your decorator? Then try lazy helpers:

```ruby
class ArticleDecorator < Draper::Base
  decorates :article
  include Draper::LazyHelpers

  def published_at
    date = content_tag(:span, article.published_at.strftime("%A, %B %e").squeeze(" "), :class => 'date')
    time = content_tag(:span, article.published_at.strftime("%l:%M%p"), :class => 'time').delete(" ")
    content_tag :span, date + time, :class => 'created_at'
  end
end
```

### In the Controller

When writing your controller actions, you have three options:

* Call `.new` and pass in the object to be wrapped

```ruby
ArticleDecorator.new(Article.find(params[:id]))
```

* Call `.decorate` and pass in an object or collection of objects to be wrapped:

```ruby
ArticleDecorator.decorate(Article.first) # Returns one instance of ArticleDecorator
ArticleDecorator.decorate(Article.all)   # Returns an enumeration proxy of ArticleDecorator instances
```

* Call `.find` to automatically do a lookup on the `decorates` class:

```ruby
ArticleDecorator.find(1)
```

### In Your Views

Use the new methods in your views like any other model method (ex: `@article.published_at`):

```erb
<h1><%= @article.title %> <%= @article.published_at %></h1>
```

### Integration with RSpec

Using the provided generator, Draper will place specs for your new decorator in `spec/decorators/`.

By default, specs in `spec/decorators` will be tagged as `type => :decorator`. Any spec tagged as `decorator` will make helpers available to the decorator.

If your decorator specs live somewhere else, which they shouldn't, make sure to tag them with `type => :decorator`. If you don't tag them, Draper's helpers won't be available to your decorator while testing.

Note: If you're using Spork, you need to `require 'draper/test/rspec_integration'` in your Spork.prefork block.

## Possible Decoration Methods

Here are some ideas of what you might do in decorator methods:

* Implement output formatting for `to_csv`, `to_json`, or `to_xml`
* Format dates and times using `strftime`
* Implement a commonly used representation of the data object like a `.name` method that combines `first_name` and `last_name` attributes

## Learning Resources

### RailsCast

Ryan Bates has put together an excellent RailsCast on Draper based on the 0.8.0 release: http://railscasts.com/episodes/286-draper

### Example Using a Decorator

For a brief tutorial with sample project, check this out: http://tutorials.jumpstartlab.com/topics/decorators.html

Say I have a publishing system with `Article` resources. My designer decides that whenever we print the `published_at` timestamp, it should be constructed like this:

```html
<span class='published_at'>
  <span class='date'>Monday, May 6</span>
  <span class='time'>8:52AM</span>
</span>
```

Could we build that using a partial? Yes. A helper? Uh-huh. But the point of the decorator is to encapsulate logic just like we would a method in our models. Here's how to implement it.

First, follow the steps above to add the dependency and update your bundle.

Since we're talking about the `Article` model we'll create an `ArticleDecorator` class. You could do it by hand, but use the provided generator:

```
rails generate decorator Article
```

Now open up the created `app/decorators/article_decorator.rb` and you'll find an `ArticleDecorator` class. Add this method:

```ruby
def published_at
  date = h.content_tag(:span, article.published_at.strftime("%A, %B %e").squeeze(" "), :class => 'date')
  time = h.content_tag(:span, article.published_at.strftime("%l:%M%p").delete(" "), :class => 'time')
  h.content_tag :span, date + time, :class => 'published_at'
end
```

Then you need to perform the wrapping in your controller. Here's the simplest method:

```ruby
class ArticlesController < ApplicationController
  def show
    @article = ArticleDecorator.find params[:id]
  end
end
```

Then within your views you can utilize both the normal data methods and your new presentation methods:

```ruby
<%= @article.published_at %>
```

Ta-da! Object-oriented data formatting for your view layer. Below is the complete decorator with extra comments removed:

```ruby
class ArticleDecorator < Draper::Base
  decorates :article

  def published_at
    date = h.content_tag(:span, article.published_at.strftime("%A, %B %e").squeeze(" "), :class => 'date')
    time = h.content_tag(:span, article.published_at.strftime("%l:%M%p"), :class => 'time').delete(" ")
    h.content_tag :span, date + time, :class => 'published_at'
  end
end
```

### Example of Decorated Associations

Add a `decorates_association :association_name` to gain access to a decorated version of your target association.

```ruby
class ArticleDecorator < Draper::Base
  decorates :article
  decorates_association :author # belongs_to :author association
end

class AuthorDecorator < Draper::Base
  decorates :author

  def fancy_name
    "#{model.title}. #{model.first_name} #{model.middle_name[0]}. #{model.last_name}"
  end
end
```

Now when you call the association it will use a decorator.

```ruby
<%= @article.author.fancy_name %>
```

### A note on Rails configuration

Draper loads your application's decorators when Rails start. This may lead to an issue with configuring I18n, whereby the settings you provide in `./config/application.rb` are ignored. This happens when you use the `I18n` constant at the class-level in one of the models that have a decorator, as in the following example:

```ruby
# app/models/user.rb
class User < ActiveRecord::Base
  validates :email, presence: { message: I18n.t('invalid_email') }
end

# app/decorators/user_decorator.rb
class UserDecorator < ApplicationDecorator
  decorates :user
end
```

Note how the `validates` line is executed when the `User` class is loaded, triggering the initialization of the I18n framework _before_ Rails had a chance to apply its configuration.

Using `I18n` directly in your model definition **is an antipattern**. The preferred solution would be to not override the `message` option in your `validates` macro, but provide the `activerecord.errors.models.attributes.user.email.presence` key in your translation files.

## Extension gems

For automatic decoration, check out [decorates_before_rendering](https://github.com/ohwillie/decorates_before_rendering).

## Contributing

1. Fork it.
2. Create a branch (`git checkout -b my_awesome_branch`)
3. Commit your changes (`git commit -am "Added some magic"`)
4. Push to the branch (`git push origin my_awesome_branch`)
5. Send pull request

## Running tests

If it's the first time you want to run the tests, start by creating the dummy database:

```
$ rake db:migrate
```

You can then run tests by executing `rake`.

## Contributors

Draper was conceived by Jeff Casimir and heavily refined by Steve Klabnik and a great community of open source contributors.

### Core Team

* Jeff Casimir (jeff@jumpstartlab.com)
* Steve Klabnik (steve@jumpstartlab.com)
* Vasiliy Ermolovich

## License

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
