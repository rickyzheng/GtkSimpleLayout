Gem::Specification.new do |s|
  s.name = 'GtkSimpleLayout'
  s.version = '0.0.1'
  s.has_rdoc = false
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'A simpley layout for RubyGnome2'
  s.description = s.summary
  s.author = 'Ricky Zheng'
  s.email = 'ricky_gz_zheng@yahoo.co.nz'
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end
