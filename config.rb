
###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
activate :livereload

# enable blog support
activate :blog
# load dotenv file
activate :dotenv

# deploy to AWS
activate :s3_sync do |s3_sync|
  s3_sync.bucket                = ENV['AWS_BUCKET']
  s3_sync.region                = ENV['AWS_REGION']
  s3_sync.aws_access_key_id     = ENV['AWS_ACCESS']
  s3_sync.aws_secret_access_key = ENV['AWS_SECRET']
  s3_sync.delete                = false
  s3_sync.after_build           = true 
  s3_sync.prefer_gzip           = true
end

activate :cloudfront do |cf|
  cf.access_key_id     = ENV['AWS_ACCESS']
  cf.secret_access_key = ENV['AWS_SECRET']
  cf.distribution_id   = ENV['AWS_DISTID']
  cf.filter            = /\.html$/i  # default is /.*/
  cf.after_build       = true
end

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'assets/stylesheets'

set :js_dir, 'assets/javascripts'

set :images_dir, 'assets/images'

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  activate :relative_assets

  # Or use a different image path
  # set :http_path, "/Content/images/"
end
