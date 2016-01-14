# OTRS::SOPM

This gem provides a class to parse, manipulate and store SOPM files and create OPM strings from them.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'otrs-sopm'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install otrs-sopm

## Usage

First create an instance via passing the location to the .sopm file.

```ruby
sopm = OTRS::SOPM.new 'path/to/Znuny4OTRS-Package.sopm'
```

### Create version

A new version can be created via passing the wanted version number and a changelog:

```ruby
sopm_hash_structure = sopm.version('1.0.1', 'Created first bug fix.')
```

### Add build information

It's recommended to add the build host and build date to the OPM file. Give the build host as a parameter with to add the build information via:

```ruby
sopm_hash_structure = sopm.add_build_information('http://build.host.tld')
```

### Add file

To add additional files to the "FileList" structure of the (S)OPM file call this method with the path and an optional permission integer (default is 644):

```ruby
sopm_hash_structure = sopm.add_file('path/to/File.pm')

# equals

sopm_hash_structure = sopm.add_file('path/to/File.pm', 664)
```

### Store changes

In case you want to store the changes you have made to the original SOPM file call this method:

```ruby
sopm_hash_structure = sopm.store
```

### Parse SOPM file

In limited cases it might necessary to re-parse the SOPM file again. Do this with:

```ruby
sopm_hash_structure = sopm.parse
```

### Get OPM string

After all changes are made you might want to create a OPM file. To receive the OPM XML string with Base64 encoded files call this method:

```ruby
opm_xml_string = sopm.opm
```

## Planned and wanted features

Feel free to implement one of those or any other:

* Accept filehandle as constructor parameter.
* Accept SOPM content string as constructor parameter.
* Write OPM file instead of only returning the string.
* Manipulate all the other attributes.
* Create SOPM file from a Hash structure.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Tests

The tests are currently in an external project since there is business logic in them. In future releases this tests will be added to this gem repository as it should be.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/znuny/otrs-sopm. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
