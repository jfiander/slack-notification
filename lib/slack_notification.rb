# frozen_string_literal: true

require 'slack_notification/version'

class SlackNotification
  attr_accessor :type, :dryrun, :title, :fallback, :fields, :channel

  def initialize(options = {})
    @channel = validated_channel(options[:channel].to_s)
    @type = validated_type(options[:type])
    @title = options[:title]
    @fallback = options[:fallback]
    @dryrun = options[:dryrun] || (defined?(Rails) && Rails.env.test?)
    @fields = validated_fields(options[:fields])
  end

  def data
    @data = {}
    @data['title'] = @title || 'Notification'
    @data['fallback'] = @fallback || @data['title']
    @data['fields'] = @fields if @fields.present?
    @data['color'] = slack_color
    @data['footer'] = Rails.env if defined?(Rails)
    @data
  end

  def notify!
    @dryrun ? data : notifier.post(attachments: [data])
  end

private

  def notifier
    raise "Missing notifier url for #{@channel}." if slack_urls[@channel].blank?

    Slack::Notifier.new(slack_urls[@channel])
  end

  def validated_fields(fields)
    if fields.is_a?(Hash)
      fields = fields_from_hash(fields)
    elsif fields.is_a?(String)
      @title = fields
      fields = []
    elsif !fields.is_a?(Array)
      raise ArgumentError, 'Unsupported fields format.'
    end

    fields.is_a?(Hash) ? fields_from_hash(fields) : fields
  end

  def fields_from_hash(hash)
    hash.map do |title, value|
      { 'title' => title, 'value' => value, 'short' => true }
    end
  end

  def slack_color
    return '#CCCCCC' if @type.blank?

    {
      success: '#1086FF', info: '#99CEFF',
      warning: '#FF6600', failure: '#BF0D3E'
    }[@type]
  end

  def validated_channel(channel = nil)
    channel = channel.delete('#')
    unknown_channel if channel.present? && !channel.in?(slack_urls.keys)

    channel = 'notifications' if channel.blank?
    channel = 'test' unless Rails.env.production?
    channel
  end

  def unknown_channel
    raise ArgumentError, 'Unknown channel.'
  end

  def slack_urls
    ENV.select { |k, _| k.match?(/SLACK_URL_/) }.map do |key, url|
      { key.gsub('SLACK_URL_', '').downcase => url }
    end.reduce({}, :merge)
  end

  def validated_type(type = nil)
    valid_types = %i[success info warning failure]
    return type if type.blank? || type.in?(valid_types)

    raise ArgumentError, 'Unrecognized notification type.'
  end
end
