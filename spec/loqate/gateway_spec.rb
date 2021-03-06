require 'loqate/gateway'

RSpec.describe Loqate::Gateway do
  let(:gateway) { described_class.new(api_key: 'fake') }

  describe '#address' do
    it 'returns an address gateway' do
      expect(gateway.address).to be_an_instance_of(Loqate::Address::Gateway)
    end
  end

  describe '#geocoding' do
    it 'returns a geocoding gateway' do
      expect(gateway.geocoding).to be_an_instance_of(Loqate::Geocoding::Gateway)
    end
  end

  describe '#phone' do
    it 'returns a phone gateway' do
      expect(gateway.phone).to be_an_instance_of(Loqate::Phone::Gateway)
    end
  end

  describe '#email' do
    it 'returns an email gateway' do
      expect(gateway.email).to be_an_instance_of(Loqate::Email::Gateway)
    end
  end

  describe '#bank' do
    it 'returns a bank gateway' do
      expect(gateway.bank).to be_an_instance_of(Loqate::Bank::Gateway)
    end
  end
end
