# To build and install, use
#     gem build gemspec.rb 
#     sudo gem install Hecatae-0.0.1.gem 
# This code is cribbed from p 257 of Practical Ruby Gems by David Berube
SPEC = Gem::Specification.new do |spec|
  spec.name = "Hecatae"
  spec.version = "0.0.1"
  spec.summary = "The 3-in-1 Validator: wrapper for Tidy, OnSGMLS and Raakt."

  #spec.add_dependency("open3")
  spec.add_dependency("mechanize")
  spec.add_dependency("raakt")
  #spec.add_dependency("uri")
  #spec.add_dependency("net/http")

  require 'rake'

  unfiltered_files = FileList['*']
  spec.files = unfiltered_files.delete_if do |filename|
    filename.include?(".gem") || filename.include?("gemspec")
  end

  spec.has_rdoc = true

  spec.require_path = "."
  spec.autorequire = "hecatae.rb"

end
