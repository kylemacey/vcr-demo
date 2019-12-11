describe Fortune do
  subject(:fortune) { described_class.new(Time.new("2019-01-01")) }

  describe "#message" do
    it "has today's formatted date" do
      expect(subject.message).to match(%r{01/01/19})
    end

    it "outputs a fortune on a new line" do
      expect(subject.message).to match(/\n\w+/)
    end
  end
end