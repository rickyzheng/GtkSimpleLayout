Gem::Specification.new do |s|
  s.name = 'GtkSimpleLayout'
  s.version = '0.1.0'
  s.has_rdoc = false
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'A simple builder style layout helper for RubyGnome2'
  s.description = s.summary
  s.author = 'Ricky Zheng'
  s.email = 'ricky_gz_zheng@yahoo.co.nz'
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{example,lib}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end
