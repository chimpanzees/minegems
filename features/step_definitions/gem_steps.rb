When /^I attach "([^"]*)"$/ do |rubygem|
  attach_file('gem_file', path_to_gem(rubygem))
end

Given /^a gem "([^"]*)" by "([^"]*)"$/ do |rubygem, subdomain|
  subdomain = Subdomain.find_or_create_by_tld_and_name(subdomain, subdomain.titleize)
  Rubygem.create_version(rubygem_file(rubygem), subdomain)
end

Then /^"([^"]*)" gem should exist for "([^"]*)"$/ do |rubygem, subdomain|
  assert_valid_gem_for_subdomain(rubygem, subdomain)
end

Then /^"([^"]*)" gem prerelease should exist for "([^"]*)"$/ do |rubygem, subdomain|
  rubygem, version, subdomain = assert_valid_gem_for_subdomain(rubygem, subdomain)
  rubygem.version(version).should be_prerelease
end

Then /^"([^"]*)" gem should not exist for "([^"]*)"$/ do |rubygem, subdomain|
  rubygems, version = find_gem(rubygem)
  subdomain = Subdomain.by_tld(subdomain).first

  rubygems.should_not be_empty
  rubygems.size.should == 1
  subdomain.rubygems.should_not include(rubygems.first)
end

module RubygemsHelper
  def path_to_gem(rubygem)
    ::File.dirname(__FILE__) + "/../../spec/support/factories/gems/#{rubygem}"
  end

  def find_gem(rubygem)
    rubygem, version = rubygem.split '/'
    rubygems = Rubygem.by_name(rubygem)

    [ rubygems, version ]
  end

  def assert_valid_gem_for_subdomain(rubygem, subdomain)
    rubygems, version = find_gem(rubygem)
    subdomain = Subdomain.by_tld(subdomain).first

    rubygems.should_not be_empty
    rubygems.size.should == 1
    rubygems.first.version(version).should_not be_nil
    subdomain.rubygems.should include(rubygems.first)

    [rubygems.first, version, subdomain]
  end
end

World(RubygemsHelper)