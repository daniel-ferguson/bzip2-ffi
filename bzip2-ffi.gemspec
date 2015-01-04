Gem::Specification.new do |s|
  s.name = 'bzip2-ffi'
  s.version = '0.0.1'
  s.summary = 'Reads and writes bzip2 compressed data using FFI bindings for libbz2.'
  s.description = <<-EOF
    Bzip2::FFI is a wrapper for libbz2 using FFI bindings. Bzip2 compressed data
    can be read and written as a stream using the Reader and Writer classes.
  EOF
  s.author = 'Philip Ross'
  s.email = 'phil.ross@gmail.com'
  s.license = 'MIT'
  s.files = %w(bzip2-ffi.gemspec) +
            Dir['lib/**/*.rb'] +
            Dir['test/**/*.rb'] +
            Dir['test/fixtures/*']
  s.platform = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rdoc_options << '--title' << 'Bzip2::FFI'
  s.extra_rdoc_files = ['LICENSE']
  s.required_ruby_version = '>= 1.9.3'
  s.add_runtime_dependency 'ffi', '~> 1.0'
  s.requirements << 'libbz2.(so|dll|dylib) available on the library search path'
end
