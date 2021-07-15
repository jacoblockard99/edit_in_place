# EditInPlace

[![Gem Version](https://badge.fury.io/rb/edit_in_place.svg)](https://badge.fury.io/rb/edit_in_place)
[![Build Status](https://travis-ci.com/jacoblockard99/edit_in_place.svg?branch=master)](https://travis-ci.com/jacoblockard99/edit_in_place)
[![Inline docs](http://inch-ci.org/github/jacoblockard99/edit_in_place.svg?branch=master)](http://inch-ci.org/github/jacoblockard99/edit_in_place)
[![Maintainability](https://api.codeclimate.com/v1/badges/389fc591cd9cccb2ceb1/maintainability)](https://codeclimate.com/github/jacoblockard99/edit_in_place/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/389fc591cd9cccb2ceb1/test_coverage)](https://codeclimate.com/github/jacoblockard99/edit_in_place/test_coverage)

`edit_in_place` is a Rails plugin that facilitates the creation of user interfaces that allow the user to edit content "in place" in a natural way. `edit_in_place` aims to be:
  - **Flexible.** Everything has been designed with extensibility in mind. The `edit_in_place` core (this repository) can be extended for a huge variety of use cases.
  - **Reliable.** Every aspect of the plugin is thoroughly tested and documented.
  - **Natural.** Coding with `edit_in_place` is just as natural as editing content with it is! We think you'll really enjoy working with the `edit_in_place` API.

## Links

  - [API Docs](https://rubydoc.info/github/jacoblockard99/edit_in_place)
  - [CHANGELOG.md](CHANGELOG.md)
  - [Releases](https://github.com/jacoblockard99/edit_in_place/releases)

## Installation

`edit_in_place` is a Ruby gem. If you use Bundler, you may install it by adding it to your `Gemfile`, like so:

```ruby
gem 'edit_in_place'
```

And then execute:
```bash
$ bundle install
```

Or you may install it manually with:
```bash
$ gem install edit_in_place
```

`edit_in_place` currently has two dependencies: `rails` and `middlegem`.

## Concepts

`edit_in_place` is—at the most fundamental level—a tool to render content in different _modes_.

This begins with the concept of a _field_, which is a single, self-contained piece of modal content. Given the same input, but different modes, a field can be rendered differently. This functionality could be used in a variety of cases, but is especially useful for creating "editable content". As an example, imagine that we have built a static website. On that website, we would like to allow the owner to modify certain parts of it. The way we would approach this with `edit_in_place` is to make each editable portion of the page a field. Then, when the site is being viewed by a visitor, we render all the fields in a `:viewing` mode, but when being edited by the owner, an `:editing` mode. Each field is then rendered differently, given the appropriate mode. A "text" field, for example, might render plain text in a `:viewing` mode, but some kind of text input in an `:editing` mode.

A _field type_ is a subclass of `EditInPlace::FieldType` that is essentially a template for a field. Given various options, including a mode, it is in charge of actually rendering the field.

To render a field, the `EditInPlace::Builder#field` method is used. Given a field type, field options, and an input, it will merge the field options with the default ones, transform the input as appropriate, and use the `FieldType` to render the content, returning the result. This is where the flexibility of `edit_in_place` begins to reveal itself: you see, the "input" given to `#field` is completely arbitrary! In other words, you can set up field types to accept whatever input they need to render the field. That means that you have virtually limitless options for how exactly you acquire and save editable data—`edit_in_place` doesn't care.

Furthermore, `edit_in_place` has the concept of field "middlewares". You can pass middlewares ([`middlegem`](https://github.com/jacoblockard99/middlegem/) is used for middlewares) to `#field` that can arbitrarily transform its input. This can be used for a host of things—transforming the data, validating the input, adding arguments to the input based on context, or really anything you want.

Of course, with this power comes significant verbosity. With only the `edit_in_place` core, you would need to set everything up yourself. However, in many cases, editable content with `edit_in_place` follows a fairly set pattern: "models" (not necessarily ActiveRecord ones) store editable attribtues; an `edit_in_place` field corresponds to one (or occasionally more) attributes; and the "editable" version of a field is a form input which allows the data to be saved back to a data store. For this functionality, see the `edit_in_place` extension [`models_in_place`](https://github.com/jacoblockard99/models_in_place).

## Usage

### Field Types

A fair amount of configuration is required to get started with `edit_in_place` if you're not using `models_in_place`. The first step is to define some field types, which provide templates for generated fields. This can be done by extended the `FieldType` class and doing one of the following:
  1. Overriding the `render` method, which is called regardless of the mode.
  2. Relying on the default `render` implementation, and overriding one of the `render_*` that it will call.
Here are a few examples:

```ruby
# text_field_type.rb

class TextFieldType < EditInPlace::FieldType
  protected

  def render_viewing(options, name, value)
    options.view.tag.p value
  end

  def render_editing(options, name, value)
    options.view.text_field_tag name, value
  end
end
```

```ruby
# boolean_field_type.rb

class DummyFieldtype < EditInPlace::FieldType
  def render(options, *)
    "You are currently #{options.mode} the webpage!"
  end
end
```

Notice that the `render` method is passed an options parameter, which is an instance of `EditInPlace::FieldOptions`, that contains the view context and the mode. Also note how `render_viewing` and `render_editing` will be called according to the current mode. If you want to define a `render_*` method for a different mode, you'll need to override the `supported_modes` method, like so:

```ruby
class LockedField
  protected

  def render_viewing(*)
    'You are viewing this field!'
  end
  
  def render_editing(*)
    'You are editing this field!'
  end

  def render_admin_editing(*)
    'You are editing this field as an admin!'
  end

  def supported_modes
    [:viewing, :editing:, :admin_editing]
  end
end
```

Attempts to call `render` with a mode that is not is `supported_modes` will result in an `EditInPlace::UnsupportedModeError`, even if the field type has a corresponding `render_*` method.

As mentioned earlier, one of the aims of `edit_in_place` is to be natural for the developer. Thus, in the interests of convenience, `edit_in_place` allows you to "register" field types with a name, making them easier to use. We might register our "text" field type, for example, like this:

```ruby
EditInPlace.configure do |c|
  c.field_types.register :text, TextFieldType.new
end
```

Now this:

```erb
<%= @builder.field TextFieldType.new, 'contact_name', 'Jacob' %>
```

Becomes:

```erb
<%= @builder.field :text, 'contact_name', 'Jacob' %>
```

Note that field type names must be symbols—strings are not allowed. Also note that duplicate registrations are not alowed and will raise an `EditInPlace::DuplicateRegistrationError`.

### Configuring a Builder

The next step is creating and using an `EditInPlace::Builder` instance. A builder always has an `EditInPlace::Configuration` instance that contains all its options and context. When a builder is first instantiated, its configuration is copied from the global `EditInPlace` configuration. Thus, you can set any global configuration options using `EditInPlace.config` or `EditInPlace.configure`, and all builders with use those options by default. For example:

```ruby
EditInPlace.configure do |c|
  c.field_options.mode = :editing
end
```

This would make editing the *default* mode. Then, you can modify builder-specific configuration using `Builder#config` or `Builder#configure`, like so:

```ruby
@builder = Builder.new # current mode is :editing
@builder.config.field_options.mode = :viewing # switched to :viewing
```

Both `EditInPlace.config` and `Builder#config` are `EditInPlace::Configuration` instances, so you configure them identically. You are encouraged to check out the [docs](https://rubydoc.info/github/jacoblockard99/edit_in_place/EditInPlace/Configuration) on `Configuration` to see all the available configuration options.

Only two options are really critical to using the builder: the view context and the mode. The view context is necessary when the field type needs access to a view context to render the field. In our `TextFieldType` example above, for example, the `text_field_tag` method was required. Probably the easiest way to pass the view context is to simply use the `view_context` method in Rails controllers. For example:

```
class SomeController
  def index
    @builder = Builder.new
    @builder.field_options.view = view_context
  end
end
```

Now, field types will automatically have access to the view context. This method has some pitfalls, however, most importantly that `view_context` returns a _new_ view context, not the one used in the actual view. If you must have the actual view context object, something like this could be done instead:

```erb
<% @builder.field_options.view = self %>

<%= @builder.field :text, "hello, world" %>
```

Of course, you would need to put this at the top of all your views.

There are a few approaches to managing builder modes. One approach is to have a seperate controller for each, like so:

```ruby
class ViewingController < ApplicationController
  def index
    @builder = Builder.new

    render 'some_page'
  end
end
```

```ruby
class EditingController < ApplicationController
  def index
    @builder = Builder.new
    @builder.config.field_options.mode = :editing
    
    render 'some_page'
  end
end
```

Then, in the 'some_page' view you can use the builder in the exact same way, but get different results because of the different mode. Other options are possible, however. Use whatever works best!

### Rendering Fields

Once you have some fields types and a builder, you are ready to actually render some fields! The `Builder#field` method is used to render a field of a given type, with the given options, and the given input. For example, with our previous `TextFieldType` example:

```erb
<%= @builder.field :text, 'phone_number', '(123) 456-7890' %>
```

When viewing the site, the user would see a simple paragraph containing the phone number. When editing the site, the user would see an editable text input. Of course, the text input currently would do nothing—you are in charge of ensuring that the data actually gets saved. You can do this however you want, but typically the fields are submitted via a form or via AJAX to a controller which saves the data. As part of the philosphy of flexibility, `edit_in_place` makes no attempt whatsoever to handle any of this.

If the second argument to `Builder#field` is either a `FieldOptions` instance or a hash, then it will be used as the options for the field. For example, you could render a specific field as always editable:

```erb
<%= @builder.field :text, { mode: :editing }, 'phone_number', '(123) 456-7890' %>
```

If your field type happens to expect the first input argument to be a hash, you will need to pass an empty options hash, like this:

```erb
<%= @builder.field :some_type, {}, { option: true }, 'etc' %>
```

### Middlewares

Perhaps the most powerful feature of `edit_in_place` are the field middlewares. `edit_in_place` uses [`middlegem`](https://github/jacoblockard99/middlegem) for middlewares, which you may want to briefly review. Field middlewares allow the inputs to a field to be transformed before actually making it to the field type's `render` method. The use cases for this are limitless.

There are two steps for using field middlewares: defining them and using them. First, you must define all the middleware classes that you will be using in your application. This is to ensure that middlewares are always run in the right order. For example, let's say we have two middleware classes, one that multiplies a number by 10, and another that surrounds it with parentheses. We would define the middleware as follows:

```ruby
EditInPlace.configure do |c|
  c.defined_middleware = [
    MultiplyMiddleware,
    ParenthesesMiddleware
]
```

This will ensure that, no matter what order they're added, the `MultplyMiddleware` will always be run before the `ParenthesesMiddleware`. If a middleware is used that has not been defined, a `Middlegem::UnpermittedMiddleware` error will be raised by `middlegem`.

Next, the middlewares can be actually used. Middlewares reside in the `FieldOptions` class, meaning you have three options for adding middlewares to fields: adding it to the global `EditInPlace` configuration, adding it to the `Builder` configuration, and passing them to `Builder#field`. You might want all fields to be surrounded in parentheses, for example, but only some to be multiplied by ten. This could be accomplished with:

```ruby
class SomeController
  def index
    @builder = Builder.new
    @builder.config.field_options.middlewares << ParenthesesMiddleware.new
  end
end
```

```erb
<%= @builder.field :text, { middlewares: [MultiplyMiddleware.new] }, 'name', '500' %>
<%= @builder.field :text, 'name', 'a string' %>
```

Now, when viewing the site, the first one would show "(5000)" and the second would show "(a string)". Note that middlewares are often too verbose to be easily used like this. They are really best used by edit_in_place extensions.

### Scoped Builders

There will likely be times when you wish for many fields to have the same `FieldOptions`. This can be accomplished with the `Builder#scoped` method, which allows field options to be shared across a block. For example:

```erb
<%= @builder.scoped middlewares: [AppendArgumentMiddleware.new('example')] |b| do %>
  <%= b.field :text, 'name', 'value' %>
<% end %>
```

Now any fields generated with the scoped `b` builder will have an `'example'` argument appended to their input (assuming that `AppendArgumentMiddleware` has been defined).

### Extending Builder

If you are developing an extension for `edit_in_place`, you may wish to add methods to `Builder`. While you could create a subclass, subclassing has its share of problems. You could not, for example, use multiple builder subclasses at once. Thus, `edit_in_place` provides an `ExtendedBuilder` class which you can use to add **new** methods to `Builder`. Essentially, `ExtendedBuilder` stores a base builder and delegates all missing method calls to it. You can use it like:

```ruby
class MyBuilderExtension < EditInPlace::ExtendedBuilder
  def hello
    'Hello, world!'
  end
end
```

And then instantiate it:

```ruby
class SomeController < ApplicationController
  def index
    base = Builder.new
    @my_builder = MyBuilderExtension.new(base)
  end
end
```

Then, in the view:

```erb
<%= @my_builder.hello %>
```

These builder extension can be chained as many times as desired. Please note however that *you should only add new methods*, never override existing ones. If you override existing methods, further down the chain, that method may be called, and will not be sent to your extension, which could cause some confusing results.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
