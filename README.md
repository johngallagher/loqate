# Loqate

[![Gem Version](https://badge.fury.io/rb/loqate.svg)](https://badge.fury.io/rb/loqate)
[![Build Status](https://travis-ci.org/wilsonsilva/loqate.svg?branch=master)](https://travis-ci.org/wilsonsilva/loqate)
[![Maintainability](https://api.codeclimate.com/v1/badges/5c1414d5dedc68c15533/maintainability)](https://codeclimate.com/github/wilsonsilva/loqate/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/5c1414d5dedc68c15533/test_coverage)](https://codeclimate.com/github/wilsonsilva/loqate/test_coverage)
[![Security](https://hakiri.io/github/wilsonsilva/loqate/master.svg)](https://hakiri.io/github/wilsonsilva/loqate/master)
[![Inline docs](http://inch-ci.org/github/wilsonsilva/loqate.svg?branch=master)](http://inch-ci.org/github/wilsonsilva/loqate)

Client to address verification, postcode lookup, & data quality services from Loqate.

## Table of contents
- [Installation](#installation)
- [Usage](#usage)
  - [Getting started](#getting-started)
  - [Bang methods](#bang-methods)
    - [Example of using non-bang method](#example-of-using-non-bang-method)
    - [Example of using bang method](#example-of-using-bang-method)
  - [Address API](#address-api)
    - [Finding addresses](#finding-addresses)
    - [Retrieving the details of an address](#retrieving-the-details-of-an-address)
  - [Phone API](#phone-api)
    - [Validating a phone number](#validating-a-phone-number)
  - [Email API](#phone-api)
    - [Validating an email address](#validating-an-email-address)
    - [Validating multiple email addresses](#validating-multiple-email-addresses)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'loqate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install loqate

## Usage

### Getting started

Loqate provides multiple APIs. And each API provides several services. This gem exposes these APIs through
an API gateway.

To get started, initialize an API gateway with [your API key](https://account.loqate.com/account#/):

```ruby
gateway = Loqate::Gateway.new(api_key: '<YOUR_API_KEY>')
```

### Bang methods

Most methods have a bang and a non-bang version (e.g. `gateway.address.find` and `gateway.address.find!`).
The non-bang version will either return a `Loqate::Success` or an `Loqate::Failure`. The bang version will
either return the desired resource, or it will raise an exception.

#### Example of using non-bang method

```ruby
result = gateway.address.find(text: 'EC1Y 8AF', country: 'GB', limit: 5)

if result.success?
  addresses = result.value
  addresses.first.id # => 'GB|RM|B|8144611'
else
  error = result.error
  puts "Error retrieving the address: #{error.description}. Resolution: #{error.resolution}"
end

result.failure? # => false
```

#### Example of using bang method

```ruby
begin
  addresses = gateway.address.find!(text: 'EC1Y 8AF', country: 'GB', limit: 5)
  addresses.first.id # => 'GB|RM|B|8144611'
rescue Loqate::Error => e
  puts "Error retrieving the address: #{e.description}. Resolution: #{e.resolution}"
end
```

It is recommended that you use the bang methods when you assume that the data is valid and do not expect validations
to fail. Otherwise, use the non-bang methods.

### Address API

The Address API consists of two main API requests:
[Find](https://www.loqate.com/resources/support/apis/Capture/Interactive/Find/1/) request is used to narrow down a
possible list of addresses;
and a [Retrieve](https://www.loqate.com/resources/support/apis/Capture/Interactive/Retrieve/1/) request is used to
retrieve a fully formatted address.

A typical address search is made up of a series of `find` requests, followed by a `retrieve` based on the user
selection.

#### Finding addresses

```ruby
addresses = gateway.address.find!(text: 'EC1Y 8AF', country: 'GB', limit: 5)

addresses.first.id # => 'GB|RM|B|8144611'
```

#### Retrieving the details of an address

```ruby
address = gateway.address.retrieve!(id: 'GB|RM|B|8144611')

address.city        # 'London' 
address.line1       # '148 Warner Road'
address.postal_code # 'E17 7EA'
```

### Phone API

The Phone API consists of a single API request:
[Validate](https://www.loqate.com/resources/support/apis/PhoneNumberValidation/Interactive/Validate/2.2/) which starts
a new phone number validation request.

#### Validating a phone number

```ruby
phone_validation = gateway.phone.validate!(phone: '+447440029210', country: 'GB')

phone_validation.phone_number      # => '+447440029210'
phone_validation.request_processed # => true
phone_validation.is_valid          # => 'Yes' -> This is how Loqate defines validity
phone_validation.valid?            # => true
phone_validation.network_code      # => '26'
phone_validation.network_name      # => 'Telefonica UK'
phone_validation.network_country   # => 'GB'
phone_validation.national_format   # => '07440 029210'
phone_validation.country_prefix    # => 44
phone_validation.number_type       # => 'Mobile'
```

### Email API

The Email API consists of two main API requests:
[Validate](https://www.loqate.com/resources/support/apis/EmailValidation/Interactive/Validate/2/) request to validate
a single email adress; and a
[Batch Validate](https://www.loqate.com/resources/support/apis/EmailValidation/Batch/Validate/1.2/) request to
validate multiple emails at once.

#### Validating an email address
```ruby
email_validation = gateway.email.validate!(email: 'person@gmail.com')

email_validation.response_code               # => 'Valid'
email_validation.response_message            # => 'Email address was fully validated'
email_validation.email_address               # => 'person@gmail.com'
email_validation.user_account                # => 'person'
email_validation.domain                      # => 'gmail.com'
email_validation.is_disposable_or_temporary  # => false
email_validation.is_complainer_or_fraud_risk # => false
email_validation.duration                    # => 0.007366261
email_validation.valid?                      # => true
email_validation.valid_domain?               # => true
email_validation.invalid?                    # => false
email_validation.timeout?                    # => false
```

#### Validating multiple email addresses

```ruby                                                                    
email_validations = gateway.email.batch_validate!(emails: %w[person@gmail.com])
email_validation = email_validations.first

email_validation.status            # => 'Valid'
email_validation.email_address     # => 'person@gmail.com'
email_validation.account           # => 'person'
email_validation.domain            # => 'gmail.com'
email_validation.is_disposible     # => false
email_validation.is_system_mailbox # => false
email_validation.valid?            # => true
email_validation.invalid?          # => false
email_validation.unknown?          # => false
email_validation.unverified?       # => false
```
   
## Development

After checking out the repo, run `bin/setup` to install dependencies, configure git hooks and create support files.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Then add your Loqate API key to `.api_key`. It will be used by RSpec and VCR, but not stored in the codebase. 

The health and maintainability of the codebase is ensured through a set of
Rake tasks to test, lint and audit the gem for security vulnerabilities and documentation:

```
rake bundle:audit          # Checks for vulnerable versions of gems 
rake qa                    # Test, lint and perform security and documentation audits
rake rubocop               # Lint the codebase with RuboCop
rake rubocop:auto_correct  # Auto-correct RuboCop offenses
rake spec                  # Run RSpec code examples
rake verify_measurements   # Verify that yardstick coverage is at least 100%
rake yard                  # Generate YARD Documentation
rake yard:junk             # Check the junk in your YARD Documentation
rake yardstick_measure     # Measure docs in lib/**/*.rb with yardstick
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wilsonsilva/loqate.

## License

See [LICENSE](https://github.com/wilsonsilva/loqate/blob/master/LICENSE).
