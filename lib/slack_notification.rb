# frozen_string_literal: true

require 'slack-notifier'

class SlackNotification
  attr_accessor :type, :dryrun, :title, :fallback, :fields, :blocks, :channel, :only_blocks

  def initialize(options = {})
    @channel = validated_channel(options[:channel].to_s)
    @type = validated_type(options[:type])
    @title = options[:title]
    @fallback = options[:fallback]
    @dryrun = options[:dryrun] || (defined?(Rails) && Rails.env.test?)
    @only_blocks = options[:only_blocks]
    @fields = validated_fields(options[:fields])
    @blocks = options[:blocks]
    @footer = options[:footer]
  end

  def data
    @data = {}
    @data['title'] = @title || ENV['SLACK_DEFAULT_TITLE'] || 'Notification'
    @data['fallback'] = @fallback || @data['title']
    @data['fields'] = @fields if @fields
    @data['color'] = slack_color
    @data['footer'] = footer if footer
    @data
  end

  def notify!
    options = { blocks: @blocks }
    options.merge!(attachments: [data]) unless only_blocks
    @dryrun ? data : notifier.post(**options)
  end

private

  def notifier
    # :nocov:
    raise "Missing notifier url for #{@channel}." unless slack_urls[@channel]

    Slack::Notifier.new(slack_urls[@channel])
    # :nocov:
  end

  def footer
    return @footer unless @footer.nil?

    # :nocov:
    if ENV.key?('ASSET_ENVIRONMENT')
      @footer = ENV['ASSET_ENVIRONMENT']
    elsif defined?(Rails)
      @footer = Rails.env
    elsif ENV.key?('SLACK_FOOTER')
      @footer = ENV['SLACK_FOOTER']
    end
    # :nocov:

    @footer
  end

  def validated_fields(fields)
    if fields.is_a?(Hash)
      fields = fields_from_hash(fields)
    elsif fields.is_a?(String)
      @title = fields
      fields = []
    elsif !only_blocks && !fields.is_a?(Array)
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
    return '#CCCCCC' unless @type

    {
      success: '#1086FF', info: '#99CEFF',
      warning: '#FF6600', failure: '#BF0D3E'
    }[@type]
  end

  def validated_channel(channel = nil)
    channel = channel.delete('#').gsub('_', '-')
    unknown_channel(channel) unless slack_urls.keys.include?(channel)

    channel ||= 'notifications'
    channel = 'test' if defined?(Rails) && !(Rails.env.production? || Rails.env.staging?)
    channel
  end

  def unknown_channel(channel)
    raise ArgumentError, "Unknown channel: #{channel}"
  end

  def slack_urls
    return credentials_urls if credentials_urls?

    ENV.select { |k, _| k.match?(/SLACK_URL_/) }.map do |key, url|
      { key.gsub('SLACK_URL_', '').gsub('_', '-').downcase => url }
    end.reduce({}, :merge)
  end

  def credentials_urls?
    defined?(Rails) && !Rails.application.credentials.slack.nil?
  end

  def credentials_urls
    # :nocov:
    Rails.application.credentials.slack.transform_keys do |key|
      key.to_s.gsub('_', '-')
    end
    # :nocov:
  end

  def validated_type(type = nil)
    valid_types = %i[success info warning failure]
    return type if type.nil? || valid_types.include?(type)

    raise ArgumentError, 'Unrecognized notification type.'
  end
end
