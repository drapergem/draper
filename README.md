# Draper: View Models for Rails

[![Actions Status](https://github.com/drapergem/draper/workflows/CI/badge.svg?branch=master)](https://github.com/drapergem/draper/actions?query=workflow%3Aci+branch%3Amaster)
[![Code Climate](https://codeclimate.com/github/drapergem/draper.svg)](https://codeclimate.com/github/drapergem/draper)
[![Test Coverage](https://api.codeclimate.com/v1/badges/0d40c43951d516bf6985/test_coverage)](https://codeclimate.com/github/drapergem/draper/test_coverage)
[![Inline docs](http://inch-ci.org/github/drapergem/draper.svg?branch=master)](http://inch-ci.org/github/drapergem/draper)

Draper adds an object-oriented layer of presentation logic to your Rails
application.

Without Draper, this functionality might have been tangled up in procedural
helpers or adding bulk to your models. With Draper decorators, you can wrap your
models with presentation-related logic to organise - and test - this layer of
your app much more effectively.

## Why Use a Decorator?

Imagine your application has an `Article` model. With Draper, you'd create a
corresponding `ArticleDecorator`. The decorator wraps the model, and deals
*only* with presentational concerns. In the controller, you decorate the article
before handing it off to the view:

```ruby
# app/controllers/articles_controller.rb
def show
  @article = Article.find(params[:id]).decorate
end
```

In the view, you can use the decorator in exactly the same way as you would have
used the model. But whenever you start needing logic in the view or start
thinking about a helper method, you can implement a method on the decorator
instead.

Let's look at how you could convert an existing Rails helper to a decorator
method. You have this existing helper:

```ruby
# app/helpers/articles_helper.rb
def publication_status(article)
  if article.published?
    "Published at #{article.published_at.strftime('%A, %B %e')}"
  else
    "Unpublished"
  end
end
```

But it makes you a little uncomfortable. `publication_status` lives in a
nebulous namespace spread across all controllers and view. Down the road, you
might want to display the publication status of a `Book`. And, of course, your
design calls for a slightly different formatting to the date for a `Book`.

Now your helper method can either switch based on the input class type (poor
Ruby style), or you break it out into two methods, `book_publication_status` and
`article_publication_status`. And keep adding methods for each publication
type...to the global helper namespace. And you'll have to remember all the names. Ick.

Ruby thrives when we use Object-Oriented style. If you didn't know Rails'
helpers existed, you'd probably imagine that your view template could feature
something like this:

```erb
<%= @article.publication_status %>
```

Without a decorator, you'd have to implement the `publication_status` method in
the `Article` model. That method is presentation-centric, and thus does not
belong in a model.

Instead, you implement a decorator:

```ruby
# app/decorators/article_decorator.rb
class ArticleDecorator < Draper::Decorator
  delegate_all

  def publication_status
    if published?
      "Published at #{published_at}"
    else
      "Unpublished"
    end
  end

  def published_at
    object.published_at.strftime("%A, %B %e")
  end
end
```

Within the `publication_status` method we use the `published?` method. Where
does that come from? It's a method of the  source `Article`, whose methods have
been made available on the decorator by the `delegate_all` call above.

You might have heard this sort of decorator called a "presenter", an "exhibit",
a "view model", or even just a "view" (in that nomenclature, what Rails calls
"views" are actually "templates"). Whatever you call it, it's a great way to
replace procedural helpers like the one above with "real" object-oriented
programming.

Decorators are the ideal place to:
* format complex data for user display
* define commonly-used representations of an object, like a `name` method that
  combines `first_name` and `last_name` attributes
* mark up attributes with a little semantic HTML, like turning a `url` field
  into a hyperlink

## Installation

As of version 4.0.0, Draper only officially supports Rails 5.2 / Ruby 2.4 and later. Add Draper to your Gemfile.

```ruby
  gem 'draper'
```

After that, run `bundle install` within your app's directory.

If you're upgrading from a 0.x release, the major changes are outlined [in the
wiki](https://github.com/drapergem/draper/wiki/Upgrading-to-1.0).

## Writing Decorators

Decorators inherit from `Draper::Decorator`, live in your `app/decorators`
directory, and are named for the model that they decorate:

```ruby
# app/decorators/article_decorator.rb
class ArticleDecorator < Draper::Decorator
# ...
end
```

### Generators

To create an `ApplicationDecorator` that all generated decorators inherit from, run...

```
rails generate draper:install
```

When you have Draper installed and generate a controller...

```
rails generate resource Article
```

...you'll get a decorator for free!

But if the `Article` model already exists, you can run...

```
rails generate decorator Article
```

...to create the `ArticleDecorator`.

### Accessing Helpers

Normal Rails helpers are still useful for lots of tasks. Both Rails' provided
helpers and those defined in your app can be accessed within a decorator via the `h` method:

```ruby
class ArticleDecorator < Draper::Decorator
  def emphatic
    h.content_tag(:strong, "Awesome")
  end
end
```

If writing `h.` frequently is getting you down, you can add...

```
include Draper::LazyHelpers
```

...at the top of your decorator class - you'll mix in a bazillion methods and
never have to type `h.` again.

(*Note*: the `capture` method is only available through `h` or `helpers`)

### Accessing the model

When writing decorator methods you'll usually need to access the wrapped model.
While you may choose to use delegation ([covered below](#delegating-methods))
for convenience, you can always use the `object` (or its alias `model`):

```ruby
class ArticleDecorator < Draper::Decorator
  def published_at
    object.published_at.strftime("%A, %B %e")
  end
end
```

## Decorating Objects

### Single Objects

Ok, so you've written a sweet decorator, now you're going to want to put it into
action! A simple option is to call the `decorate` method on your model:

```ruby
@article = Article.first.decorate
```

This infers the decorator from the object being decorated. If you want more
control - say you want to decorate a `Widget` with a more general
`ProductDecorator` - then you can instantiate a decorator directly:

```ruby
@widget = ProductDecorator.new(Widget.first)
# or, equivalently
@widget = ProductDecorator.decorate(Widget.first)
```

### Collections

#### Decorating Individual Elements

If you have a collection of objects, you can decorate them all in one fell
swoop:

```ruby
@articles = ArticleDecorator.decorate_collection(Article.all)
```

If your collection is an ActiveRecord query, you can use this:

```ruby
@articles = Article.popular.decorate
```

*Note:* In Rails 3, the `.all` method returns an array and not a query. Thus you
_cannot_ use the technique of `Article.all.decorate` in Rails 3. In Rails 4,
`.all` returns a query so this techique would work fine.

#### Decorating the Collection Itself

If you want to add methods to your decorated collection (for example, for
pagination), you can subclass `Draper::CollectionDecorator`:

```ruby
# app/decorators/articles_decorator.rb
class ArticlesDecorator < Draper::CollectionDecorator
  def page_number
    42
  end
end

# elsewhere...
@articles = ArticlesDecorator.new(Article.all)
# or, equivalently
@articles = ArticlesDecorator.decorate(Article.all)
```

Draper decorates each item by calling the `decorate` method. Alternatively, you can
specify a decorator by overriding the collection decorator's `decorator_class`
method, or by passing the `:with` option to the constructor.

#### Using pagination

Some pagination gems add methods to `ActiveRecord::Relation`. For example,
[Kaminari](https://github.com/amatsuda/kaminari)'s `paginate` helper method
requires the collection to implement `current_page`, `total_pages`, and
`limit_value`. To expose these on a collection decorator, you can delegate to
the `object`:

```ruby
class PaginatingDecorator < Draper::CollectionDecorator
  delegate :current_page, :total_pages, :limit_value, :entry_name, :total_count, :offset_value, :last_page?
end
```

The `delegate` method used here is the same as that added by [Active
Support](http://api.rubyonrails.org/classes/Module.html#method-i-delegate),
except that the `:to` option is not required; it defaults to `:object` when
omitted.

[will_paginate](https://github.com/mislav/will_paginate) needs the following delegations:

```ruby
delegate :current_page, :per_page, :offset, :total_entries, :total_pages
```

If needed, you can then set the collection_decorator_class of your CustomDecorator as follows:
```ruby
class ArticleDecorator < Draper::Decorator
  def self.collection_decorator_class
    PaginatingDecorator
  end
end

ArticleDecorator.decorate_collection(@articles.paginate)
# => Collection decorated by PaginatingDecorator
# => Members decorated by ArticleDecorator
```

### Decorating Associated Objects

You can automatically decorate associated models when the primary model is
decorated. Assuming an `Article` model has an associated `Author` object:

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_association :author
end
```

When `ArticleDecorator` decorates an `Article`, it will also use
`AuthorDecorator` to decorate the associated `Author`.

### Decorated Finders

You can call `decorates_finders` in a decorator...

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_finders
end
```

...which allows you to then call all the normal ActiveRecord-style finders on
your `ArticleDecorator` and they'll return decorated objects:

```ruby
@article = ArticleDecorator.find(params[:id])
```

### Decorated Query Methods
By default, Draper will decorate all [QueryMethods](https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html)
of ActiveRecord.
If you're using another ORM, in order to support it, you can tell Draper to use a custom strategy:

```ruby
Draper.configure do |config|
  config.default_query_methods_strategy = :mongoid
end
```

### When to Decorate Objects

Decorators are supposed to behave very much like the models they decorate, and
for that reason it is very tempting to just decorate your objects at the start
of your controller action and then use the decorators throughout. *Don't*.

Because decorators are designed to be consumed by the view, you should only be
accessing them there. Manipulate your models to get things ready, then decorate
at the last minute, right before you render the view. This avoids many of the
common pitfalls that arise from attempting to modify decorators (in particular,
collection decorators) after creating them.

To help you make your decorators read-only, we have the `decorates_assigned`
method in your controller. It adds a helper method that returns the decorated
version of an instance variable:

```ruby
# app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  decorates_assigned :article

  def show
    @article = Article.find(params[:id])
  end
end
```

The `decorates_assigned :article` bit is roughly equivalent to

```ruby
def article
  @decorated_article ||= @article.decorate
end
helper_method :article
```

This means that you can just replace `@article` with `article` in your views and
you'll have access to an ArticleDecorator object instead. In your controller you
can continue to use the `@article` instance variable to manipulate the model -
for example, `@article.comments.build` to add a new blank comment for a form.

## Configuration
Draper works out the box well, but also provides a hook for you to configure its
default functionality. For example, Draper assumes you have a base `ApplicationController`.
If your base controller is named something different (e.g. `BaseController`),
you can tell Draper to use it by adding the following to an initializer:

```ruby
Draper.configure do |config|
  config.default_controller = BaseController
end
```

## Testing

Draper supports RSpec, MiniTest::Rails, and Test::Unit, and will add the
appropriate tests when you generate a decorator.

### RSpec

Your specs are expected to live in `spec/decorators`. If you use a different
path, you need to tag them with `type: :decorator`.

In a controller spec, you might want to check whether your instance variables
are being decorated properly. You can use the handy predicate matchers:

```ruby
assigns(:article).should be_decorated

# or, if you want to be more specific
assigns(:article).should be_decorated_with ArticleDecorator
```

Note that `model.decorate == model`, so your existing specs shouldn't break when
you add the decoration.

#### Spork Users

In your `Spork.prefork` block of `spec_helper.rb`, add this:

```ruby
require 'draper/test/rspec_integration'
```

#### Custom Draper Controller ViewContext
If running tests in an engine setting with a controller other than "ApplicationController," set a custom controller in `spec_helper.rb`

```ruby
config.before(:each, type: :decorator) do |example|
  Draper::ViewContext.controller = ExampleEngine::CustomRootController.new
end
```

### Isolated Tests

In tests, Draper needs to build a view context to access helper methods. By
default, it will create an `ApplicationController` and then use its view
context. If you are speeding up your test suite by testing each component in
isolation, you can eliminate this dependency by putting the following in your
`spec_helper` or similar:

```ruby
Draper::ViewContext.test_strategy :fast
```

In doing so, your decorators will no longer have access to your application's
helpers. If you need to selectively include such helpers, you can pass a block:

```ruby
Draper::ViewContext.test_strategy :fast do
  include ApplicationHelper
end
```

#### Stubbing Route Helper Functions

If you are writing isolated tests for Draper methods that call route helper
methods, you can stub them instead of needing to require Rails.

If you are using RSpec, minitest-rails, or the Test::Unit syntax of minitest,
you already have access to the Draper `helpers` in your tests since they
inherit from `Draper::TestCase`. If you are using minitest's spec syntax
without minitest-rails, you can explicitly include the Draper `helpers`:

```ruby
describe YourDecorator do
  include Draper::ViewHelpers
end
```

Then you can stub the specific route helper functions you need using your
preferred stubbing technique. This examples uses Rspec currently recommended API
available in RSpec 3.6+

```ruby
without_partial_double_verification do
  allow(helpers).to receive(:users_path).and_return('/users')
end
```

### View context leakage
As mentioned before, Draper needs to build a view context to access helper methods. In MiniTest, the view context is
cleared during `before_setup` preventing any view context leakage. In RSpec, the view context is cleared before each
`decorator`, `controller`, and `mailer` spec. However, if you use decorators in other types of specs
(e.g. `job`), you may still experience the view context leaking from the previous spec. To solve this, add the
following to your `spec_helper` for each type of spec you are experiencing the leakage:

```ruby
config.before(:each, type: :type) { Draper::ViewContext.clear! }
```

_Note_: The `:type` above is just a placeholder. Replace `:type` with the type of spec you are experiencing
the leakage from.

## Advanced usage

### Shared Decorator Methods

You might have several decorators that share similar needs. Since decorators are
just Ruby objects, you can use any normal Ruby technique for sharing
functionality.

In Rails controllers, common functionality is organized by having all
controllers inherit from `ApplicationController`. You can apply this same
pattern to your decorators:

```ruby
# app/decorators/application_decorator.rb
class ApplicationDecorator < Draper::Decorator
# ...
end
```

Then modify your decorators to inherit from that `ApplicationDecorator` instead
of directly from `Draper::Decorator`:

```ruby
class ArticleDecorator < ApplicationDecorator
  # decorator methods
end
```

### Delegating Methods

When your decorator calls `delegate_all`, any method called on the decorator not
defined in the decorator itself will be delegated to the decorated object. This
includes calling `super` from within the decorator. A call to `super` from within
the decorator will first try to call the method on the parent decorator class. If
the method does not exist on the parent decorator class, it will then try to call
the method on the decorated `object`. This is a very permissive interface.

If you want to strictly control which methods are called within views, you can
choose to only delegate certain methods from the decorator to the source model:

```ruby
class ArticleDecorator < Draper::Decorator
  delegate :title, :body
end
```

We omit the `:to` argument here as it defaults to the `object` being decorated.
You could choose to delegate methods to other places like this:

```ruby
class ArticleDecorator < Draper::Decorator
  delegate :title, :body
  delegate :name, :title, to: :author, prefix: true
end
```

From your view template, assuming `@article` is decorated, you could do any of
the following:

```ruby
@article.title # Returns the article's `.title`
@article.body  # Returns the article's `.body`
@article.author_name  # Returns the article's `author.name`
@article.author_title # Returns the article's `author.title`
```

### Adding Context

If you need to pass extra data to your decorators, you can use a `context` hash.
Methods that create decorators take it as an option, for example:

```ruby
Article.first.decorate(context: {role: :admin})
```

The value passed to the `:context` option is then available in the decorator
through the `context` method.

If you use `decorates_association`, the context of the parent decorator is
passed to the associated decorators. You can override this with the `:context`
option:

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_association :author, context: {foo: "bar"}
end
```

or, if you want to modify the parent's context, use a lambda that takes a hash
and returns a new hash:

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_association :author,
    context: ->(parent_context){ parent_context.merge(foo: "bar") }
end
```

### Specifying Decorators

When you're using `decorates_association`, Draper uses the `decorate` method on
the associated record(s) to perform the decoration. If you want use a specific
decorator, you can use the `:with` option:

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_association :author, with: FancyPersonDecorator
end
```

For a collection association, you can specify a `CollectionDecorator` subclass,
which is applied to the whole collection, or a singular `Decorator` subclass,
which is applied to each item individually.

### Scoping Associations

If you want your decorated association to be ordered, limited, or otherwise
scoped, you can pass a `:scope` option to `decorates_association`, which will be
applied to the collection *before* decoration:

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_association :comments, scope: :recent
end
```

### Proxying Class Methods

If you want to proxy class methods to the wrapped model class, including when
using `decorates_finders`, Draper needs to know the model class. By default, it
assumes that your decorators are named `SomeModelDecorator`, and then attempts
to proxy unknown class methods to `SomeModel`.

If your model name can't be inferred from your decorator name in this way, you
need to use the `decorates` method:

```ruby
class MySpecialArticleDecorator < Draper::Decorator
  decorates :article
end
```

This is only necessary when proxying class methods.

Once this association between the decorator and the model is set up, you can call
`SomeModel.decorator_class` to access class methods defined in the decorator.
If necessary, you can check if your model is decorated with `SomeModel.decorator_class?`.

### Making Models Decoratable

Models get their `decorate` method from the `Draper::Decoratable` module, which
is included in `ActiveRecord::Base` and `Mongoid::Document` by default. If
you're using another ORM, or want to decorate plain old Ruby objects,
you can include this module manually.

### Active Job Integration

[Active Job](http://edgeguides.rubyonrails.org/active_job_basics.html) allows you to pass ActiveRecord
objects to background tasks directly and performs the necessary serialization and deserialization. In
order to do this, arguments to a background job must implement [Global ID](https://github.com/rails/globalid).
Decorated objects implement Global ID by delegating to the object they are decorating. This means
you can pass decorated objects to background jobs, however, the object won't be decorated when it is
deserialized.

## Contributors

Draper was conceived by Jeff Casimir and heavily refined by Steve Klabnik and a
great community of open source
[contributors](https://github.com/drapergem/draper/contributors).

### Current maintainers

* Cliff Braton (cliff.braton@gmail.com)

### Historical maintainers

* Jeff Casimir (jeff@jumpstartlab.com)
* Steve Klabnik (steve@jumpstartlab.com)
* Vasiliy Ermolovich
* Andrew Haines
* Sean Linsley
