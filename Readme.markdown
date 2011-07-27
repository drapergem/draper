# Draper

This gem makes it easy to apply the decorator pattern to the models in a Rails application. This gives you three wins:

1. Replace most helpers with an object-oriented approach
2. Filter data at the presentation level
3. Enforce an interface between your controllers and view templates.

## Goals

### 1. Object Oriented Helpers

Why hate helpers? In Ruby/Rails we approach everything from an Object-Oriented perspective, then with helpers we get procedural.The job of a helper is to take in data and output a presentation-ready string. We can do that job in an OO style with a decorator.

A decorator wraps an object with presentation-related accessor methods. For instance, if you had an `Article` object, then the decorator could override `.published_at` to use formatted output like this:

```ruby
class ArticleDecorator < Draper::Base
  decorates :article
  def published_at
    date = h.content_tag(:span, published_at.strftime("%A, %B %e").squeeze(" "), :class => 'date')
    time = h.content_tag(:span, published_at.strftime("%l:%M%p"), :class => 'time').delete(" ")
    h.content_tag :span, date + time, :class => 'created_at'
  end
end
```

### 2. View-Layer Data Filtering

Have you ever written a `to_xml` or `to_json` method in your model? Did it feel weird to put what is essentially view logic in your model?

Or, in the course of formatting this data, did you wish you could access `current_user` down in the model? Maybe for guests your `to_json` is only going to show three attributes, but if the user is an admin they get to see them all.

How would you handle this in the model layer? You'd probably pass the `current_user` or some role/flag down to `to_json`. That should still feel slimy.

When you use a decorator you have the power of a Ruby object but it's a part of the view layer. This is where your `to_xml` belongs. You can access your `current_user` helper method using the `h` proxy available in the decorator:

```ruby
class ArticleDecorator < Draper::Base
  ADMIN_VISIBLE_ATTRIBUTES = [:title, :body, :author, :status]
  PUBLIC_VISIBLE_ATTRIBUTES = [:title, :body]

  def to_xml
    attr_set = h.current_user.admin? ? ADMIN_VISIBLE_ATTRIBUTES : PUBLIC_VISIBLE_ATTRIBUTES
    self.subject.to_xml(:only => attr_set)
  end
end
```

### 3. Enforcing an Interface

Want to strictly control what methods are proxied to the original object? Use `denies` or `allows`.

#### Using `denies`

The `denies` method takes a blacklist approach. For instance:

```ruby
class ArticleDecorator < Draper::Base
  denies :title
end
```

Then, to test it:

```irb
ruby-1.9.2-p290 :001 > ad = ArticleDecorator.find(1)
 => #<ArticleDecorator:0x000001020d7728 @model=#<Article id: 1, title: "Hello, World">> 
ruby-1.9.2-p290 :002 > ad.title
NoMethodError: undefined method `title' for #<ArticleDecorator:0x000001020d7728>
``` 

## Usage

### Setup

Add the dependency to your `Gemfile`:

```
gem "draper"
```

Run bundle:

```
bundle
```

### Generate the Decorator

To decorate a model named `Article`:

```
rails generate draper:model Article
```

### Writing Methods

Open the decorator model (ex: `app/decorators/article_decorator.rb`) and add normal instance methods. To access the wrapped source object, use the `model` method:

```ruby
class Article < Draper::Base
  decorates :article
  
  def author_name
    model.author.first_name + " " + model.author.last_name
  end
end
```


### Using Existing Helpers

You probably want to make use of existing helpers from Rails and your application helpers. Use the `helpers` or `h` method proxy:

```ruby
class Article < Draper::Base
  decorates :article
  
  def published_at
    date = h.content_tag(:span, published_at.strftime("%A, %B %e").squeeze(" "), :class => 'date')
    time = h.content_tag(:span, published_at.strftime("%l:%M%p"), :class => 'time').delete(" ")
    h.content_tag :span, date + time, :class => 'created_at'
  end
end
```

### In the Controller

When writing your controller actions, you have three options:

* Call `.new` and pass in the object to be wrapped

  ```ruby
  ArticleDecorator.new(Article.find(params[:id]))`
  ```

* Call `.decorate` and pass in an object or collection of objects to be wrapped:
  ```ruby
  
  ```
  
* Call `.find` to do automatically do a lookup on the `decorates` class:
  ```ruby
  
  ```
  
### In Your Views

Use the new methods in your views like any other model method (ex: `@article.published_at`):

```erb
<h1><%= @article.title %> <%= @article.published_at %></h1>
```

## An Interface with Allows/Denies

A proper interface defines a contract between two objects. One purpose of the decorator pattern is to define an interface between your data model and the view template.

You are provided class methods `allows` and `denies` to control exactly which of the subject's methods are available. By default, *all* of the subject's methods can be accessed.

For example, say you want to prevent access to the `:title` method. You'd use `denies` like this:

```ruby
  class ArticleDecorator < Draper::Base
    denies :title
  end
```

`denies` uses a blacklist approach. Note that, as of the current version, denying `:title` does not affect related methods like `:title=`, `:title?`, etc.

A better idea is a whitelist approach using `allows`:

```ruby
  class ArticleDecorator < Draper::Base
    allows :title, :body, :author
  end
```

Now only those methods and any defined in the decorator class itself can be accessed directly.

## Possible Decoration Methods

Here are some ideas of what you might do in decorator methods:

* Implement output formatting for `to_csv`, `to_json`, or `to_xml`
* Format dates and times using `strftime`
* Implement a commonly used representation of the data object like a `.name` method that combines `first_name` and `last_name` attributes

## Example Using a Decorator

For a brief tutorial with sample project, check this out: http://tutorials.jumpstartlab.com/rails/topics/decorators.html

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
rails generate draper:model Article
```

Now open up the created `app/decorators/article_decorator.rb` and you'll find an `ArticleDecorator` class. Add this method:

```ruby
def formatted_published_at
  date = h.content_tag(:span, published_at.strftime("%A, %B %e").squeeze(" "), :class => 'date')
  time = h.content_tag(:span, published_at.strftime("%l:%M%p").delete(" "), :class => 'time')
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
<%= @article.formatted_published_at %>
```

Ta-da! Object-oriented data formatting for your view layer. Below is the complete decorator with extra comments removed:

```ruby
class ArticleDecorator < Draper::Base
  decorates :article
  
  def formatted_published_at
    date = h.content_tag(:span, published_at.strftime("%A, %B %e").squeeze(" "), :class => 'date')
    time = h.content_tag(:span, published_at.strftime("%l:%M%p"), :class => 'time').delete(" ")
    h.content_tag :span, date + time, :class => 'created_at'
  end
end
```

## Issues / Pending

* Test coverage for generators
* Revise readme to better explain interface pattern
* Build sample Rails application

## License

(The MIT License)

Copyright © 2011 Jeff Casimir

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.