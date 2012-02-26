require Rails.root.join('lib', 'carrierwave', 'sanitized_file', 'compat')
require Rails.root.join('lib', 'carrierwave', 'uploader', 'compat')

$mongo = if Rails.env.production?
  require 'uri'
  uri = URI(ENV['MONGOHQ_URL'])
  db  = uri.path.gsub('/', '')
  connection, _ = Mongo::Connection.from_uri uri.to_s
  connection.db(db)
else
  Mongo::Connection.new.db('gemsmine')
end

CarrierWave.configure do |config|
  unless Rails.env.production?
    config.storage :file
    config.enable_processing false
  else
    config.storage :s3

    # FIXME use Heroku env vars
    config.s3_access_key_id     = "0WSTNF8GVS4A9AQAWWG2"
    config.s3_secret_access_key = "P0hnVy1Z8BMySyErifaCTxH4h84NRMjlHEmn8HGC"
    config.s3_bucket            = 'gemsmine'
    config.s3_access_policy     = :private

    config.grid_fs_connection = $mongo
    config.grid_fs_access_url = '/'
    config.cache_dir = Rails.root.join('tmp', 'carrierwave')
  end
end
