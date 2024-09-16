Gem::Specification.new do |s|
  s.name = 'GtkSimpleLayout'
  s.version = '0.3.1'
  s.license = 'GPL-2.0-or-later'
  s.required_ruby_version = '>= 2.5.0'
  s.homepage = "https://github.com/rickyzheng/GtkSimpleLayout"
  # s.has_rdoc = false
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'A simple builder style layout helper for Ruby GTK3'
  s.description = 'A simple builder style layout helper for Ruby GTK3, it helps you to build ruby GTK3 UI codes in a much more readable way. It also includes a UI inspector to debug the UI.'
  s.author = 'Ricky Zheng'
  s.email = 'ricky_gz_zheng@yahoo.co.nz'
  s.files = %w(LICENSE README Rakefile)
  s.files += Dir.glob("example/**/*")
  s.files += Dir.glob("lib/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end
