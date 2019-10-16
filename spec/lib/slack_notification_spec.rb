# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SlackNotification, type: :lib do
  let(:notification_with_short_three) do
    {
      'title' => 'Test Notification',
      'fallback' => 'This is a test notification',
      'fields' => [
        { 'title' => 'One', 'value' => 'one', 'short' => true },
        { 'title' => 'Two', 'value' => 'two', 'short' => true },
        { 'title' => 'Three', 'value' => 'three', 'short' => true }
      ],
      'color' => '#99CEFF'
    }
  end

  let(:notification_with_long_three) do
    notification = notification_with_short_three.dup
    notification['fields'][2]['value'] = 'three is long'
    notification['fields'][2]['short'] = false
    notification
  end

  let(:notification_with_string) do
    notification = notification_with_short_three.dup
    notification['title'] = 'Just one field'
    notification['fields'] = []
    notification
  end

  before do
    base_notification_details = {
      channel: 'test', type: :info, fields: nil, dryrun: true,
      title: 'Test Notification', fallback: 'This is a test notification'
    }

    ENV['SLACK_URL_TEST'] = 'https://slack.com/test'

    @hash_notification = SlackNotification.new(
      base_notification_details.merge(fields: { 'One' => 'one', 'Two' => 'two', 'Three' => 'three' })
    )

    @array_notification = SlackNotification.new(
      base_notification_details.merge(
        fields: [
          { 'title' => 'One', 'value' => 'one', 'short' => true },
          { 'title' => 'Two', 'value' => 'two', 'short' => true },
          { 'title' => 'Three', 'value' => 'three is long', 'short' => false }
        ]
      )
    )

    @string_notification = SlackNotification.new(
      base_notification_details.merge(fields: 'Just one field')
    )

    @live_notification = SlackNotification.new(
      base_notification_details.merge(fields: 'Just one field', channel: :test)
    )
    @live_notification.dryrun = false
  end

  it 'generates a valid notification with fields hash' do
    expect(@hash_notification.notify!).to eql(notification_with_short_three)
  end

  it 'generates a valid notification with fields array' do
    expect(@array_notification.notify!).to eql(notification_with_long_three)
  end

  it 'generates a valid notification with string' do
    expect(@string_notification.notify!).to eql(notification_with_string)
  end

  it 'rejects invalid types of fields' do
    expect do
      SlackNotification.new(
        type: :info, title: 'Test Notification',
        fallback: 'This is a test notification',
        fields: Set.new, channel: 'test',
        dryrun: true
      )
    end.to raise_error(
      ArgumentError, 'Unsupported fields format.'
    )
  end

  it 'rejects invalid types of notifications' do
    expect do
      SlackNotification.new(
        type: :not_valid, title: 'Test Notification',
        fallback: 'This is a test notification',
        fields: 'String', channel: 'test',
        dryrun: true
      )
    end.to raise_error(
      ArgumentError, 'Unrecognized notification type.'
    )
  end

  it 'rejects unlinked channels' do
    expect do
      SlackNotification.new(
        channel: 'not-valid',
        type: :info, title: 'Test Notification',
        fallback: 'This is a test notification',
        fields: 'String',
        dryrun: true
      )
    end.to raise_error(
      ArgumentError, 'Unknown channel: not-valid'
    )
  end

  # it 'successfully sends a notification' do
  #   expect { @live_notification.notify! }.not_to raise_error
  # end
end
