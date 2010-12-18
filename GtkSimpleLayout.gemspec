Gem::Specification.new do |s|
  s.name = 'GtkSimpleLayout'
  s.version = '0.2.1'
  s.has_rdoc = false
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'A simple builder style layout helper for RubyGnome2'
  s.description = s.summary
  s.author = 'Ricky Zheng'
  s.email = 'ricky_gz_zheng@yahoo.co.nz'
  s.files = %w(LICENSE README Rakefile)
  s.files += Dir.glob("example/**/*")
  s.files += Dir.glob("lib/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end
