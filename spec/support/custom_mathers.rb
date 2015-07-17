require 'rspec/expectations'

RSpec::Matchers.define :be_the_same_time do |expected|
  match do |actual|
    expect(expected.strftime('%Y-%m-%dT%H:%M:%S%z').in_time_zone).to eq(actual.strftime('%Y-%m-%dT%H:%M:%S%z').in_time_zone)
  end
end
