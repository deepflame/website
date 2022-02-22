# Methods defined in the helpers block are available in templates
helpers do
  # font awesome helper
  def icon(icon, text = nil, html_options = {})
    text, html_options = nil, text if text.is_a?(Hash)

    content_class = "fa fa-#{icon}"
    content_class << " #{html_options[:class]}" if html_options.key?(:class)
    html_options[:class] = content_class

    html = content_tag(:i, nil, html_options)
    html << ' ' << text.to_s unless text.blank?
    html
  end


  def enable_commenting?
    false
  end
end

Time.zone = "UTC" # used for Blog articles

config[:css_dir] = 'assets/stylesheets'
config[:js_dir] = 'assets/javascripts'
config[:images_dir] = 'assets/images'
config[:fonts_dir] = 'assets/fonts'

postcss_command = './node_modules/.bin/postcss source/assets/stylesheets/tailwind.pcss --output .tmp/postcss/assets/stylesheets/tailwind.css'
activate :external_pipeline,
  name: :postcss,
  command: build? ?  postcss_command : "#{postcss_command} --watch",
  source: ".tmp/postcss",
  latency: 1

activate :blog do |blog|
  blog.prefix = "blog"

  blog.permalink = "{year}/{month}/{title}.html"
  blog.sources = "articles/{year}-{month}-{day}-{title}.html" # Matcher for blog source files
  blog.layout = "blog"
  blog.summary_separator = /(READMORE)/
  blog.summary_length = 250
  blog.default_extension = ".md"

  blog.tag_template = "blog/tag.html"
  blog.calendar_template = "blog/calendar.html"

  # Enable pagination
  blog.paginate = false
  blog.per_page = 10
  blog.page_link = "page/{num}"
end
page "/blog/feed.xml", layout: false

activate :directory_indexes

activate :syntax
set :markdown_engine, :redcarpet
set :markdown,
#     :no_intra_emphasis => true,
#     :tables => true,
      :fenced_code_blocks => true,
#     :autolink => true,
#     :strikethrough => true,
#     :lax_html_blocks => true,
#     :space_after_headers => true,
#     :with_toc_data => true,
#     :superscript => true,
      :smartypants => true
#     :hard_wrap => true

# deploy to AWS
activate :s3_sync do |s3|
  s3.bucket                = ENV['AWS_BUCKET']
  s3.region                = ENV['AWS_REGION']
  s3.aws_access_key_id     = ENV['AWS_ACCESS']
  s3.aws_secret_access_key = ENV['AWS_SECRET']
  s3.delete                = false
  s3.prefer_gzip           = true
  #s3.after_build           = true
end

activate :cloudfront do |cf|
  cf.access_key_id     = ENV['AWS_ACCESS']
  cf.secret_access_key = ENV['AWS_SECRET']
  cf.distribution_id   = ENV['AWS_DISTID']
  cf.filter            = /\.html$/i  # default is /.*/
  #cf.after_build       = true
end

# Development-specific configuration
configure :development do
  activate :dotenv
  activate :livereload, apply_css_live: true,
    host: '0.0.0.0',
    js_host: gitpod? ? gitpod_host(port: 35729) : '127.0.0.1',
    js_port: gitpod? ? 35729 : 443 unless gitpod? # disable if on Gitpod (not working, plugin does not support wss)
end

# Build-specific configuration
configure :build do
  activate :autoprefixer do |config|
    config.browsers = ['last 2 versions', 'Explorer >= 9']
  end
  activate :minify_css
  activate :minify_javascript
  activate :asset_hash
  activate :relative_assets
  ignore '**/LICENSE'
  ignore '*.pcss'
end

# private

def gitpod?
  ENV['GITPOD_WORKSPACE_ID']
end

def gitpod_host(port:)
  `gp url #{port}`.gsub("https://", '').gsub("\n", '')
end

