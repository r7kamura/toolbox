# frozen_string_literal: true

require 'google/apis/drive_v3'
require 'securerandom'

class GoogleDriveWatch
  SCOPES = %w[
    https://www.googleapis.com/auth/drive
    https://www.googleapis.com/auth/drive.file
  ].freeze

  # @param [String] credentials_path
  # @param [String] webhook_url
  def initialize(
    credentials_path:,
    webhook_url:
  )
    @credentials_path = credentials_path
    @webhook_url = webhook_url
  end

  def call
    p watch
  end

  private

  # @return [Google::Auth::ServiceAccountCredentials]
  def authorize
    credentials = ::Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: credentials_file,
      scope: SCOPES
    )
    credentials.fetch_access_token!
    credentials
  end

  # @return [File]
  def credentials_file
    ::File.open(@credentials_path)
  end

  # @return [String]
  def fetch_changes_start_page_token
    service.get_changes_start_page_token.start_page_token
  end

  # @return [Google::Apis::DriveV3::DriveService]
  def service
    @service ||= begin
      object = ::Google::Apis::DriveV3::DriveService.new
      object.authorization = authorize
      object
    end
  end

  # @return [Google::Apis::DriveV3::Channel]
  def watch
    service.watch_change(
      fetch_changes_start_page_token,
      ::Google::Apis::DriveV3::Channel.new(
        address: @webhook_url,
        id: ::SecureRandom.uuid,
        type: 'web_hook'
      )
    )
  end
end

GoogleDriveWatch.new(
  credentials_path: ::ENV['GOOGLE_APPLICATION_CREDENTIALS'],
  webhook_url: ::ENV['WEBHOOK_URL']
).call
