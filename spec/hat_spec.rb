describe Hat, :vcr do
  subject(:hat) { described_class.new }

  describe "#random_fortune" do
    subject(:fortune) { hat.random_fortune }

    it { is_expected.to be_a(Fortune) }

    it "gets a fortune from one of its fortunes" do
      expect(hat.fortunes).to include(fortune)
    end
  end
end