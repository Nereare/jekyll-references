# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'jekyll-references'
  spec.author = 'Igor Padoim'
  spec.email = 'igorpadoim@gmail.com'

  spec.version = '1.1.0-r1'
  spec.license = 'WTFPL'
  spec.summary = 'Create Liquid tags to parse and show reference lists'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/Nereare/jekyll-references/'

  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['bug_tracker_uri'] = 'https://github.com/Nereare/jekyll-references/issues'
  spec.metadata['source_code_uri'] = 'https://github.com/Nereare/jekyll-references'
  spec.metadata['changelog_uri'] = 'https://github.com/Nereare/jekyll-references/blob/master/CHANGELOG.md'

  spec.require_paths = ['lib']
  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r!^(test|spec|features|pkg)/!) }

  spec.add_dependency 'jekyll', '~> 4.4'
end
