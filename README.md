# SlackNotification

[![Gem Version](https://img.shields.io/gem/v/slack-notification.svg)](https://rubygems.org/gems/slack-notification)
[![Build Status](https://travis-ci.org/jfiander/slack-notification.svg)](https://travis-ci.org/jfiander/slack-notification)

This is a simplified API for sending Slack messages from (e.g.) a Rails application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'slack-notification'
```

And then execute:

```sh
bundle
```

Or install it yourself as:

```sh
gem install slack-notification
```

## Usage

```ruby
SlackNotification.new(
  channel: 'channel-name-here', type: :success, title: 'Something Happened',
  fallback: "Plain-text version of the message.",
  fields: [
    { title: 'Field one', value: value_one, short: true },
    { title: 'Field two', value: value_two, short: true },
    { title: 'Longer field that needs more space.', value: value_three, short: false }
  ]
).notify!
```

Options:

```ruby
:type     # Notification type (see below)
:dryrun   # Do not actually submit the message
:title    # Title for the message
:fallback # Plain-text version for if fields won't work
:fields   # Regular data for the message
:channel  # The channel webhook to submit to
```

Available notification types:

```ruby
%i[success info warning failure]
```

Fields can be formatted in several ways:

- String: The fields value becomes the message title, and no fields are submitted.
- Hash:   Format: `{ title_1: :value_1, [...] }`
- Array:  Array of hashes, each of format: `{ title: 'Field name', value: field_value, short: true }`

### Configuration

Channels can be made available by setting ENV variables beginning with `SLACK_URL_`.

If you are using Rails credentials, the `:slack` will take priority over ENV variables, if present.

The title field will default to `ENV['SLACK_DEFAULT_TITLE']`, if present.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
