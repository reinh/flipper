require 'set'

# Requires the following methods
# subject
# read_key(key)
# write_key(key, value)
shared_examples_for 'a flipper adapter' do
  let(:key) { Flipper::Key.new(:foo, :bar) }

  describe "#write" do
    it "sets key to value in store" do
      subject.write(key, true)
      read_key(key).should be_true
    end
  end

  describe "#read" do
    it "returns nil if key not in store" do
      subject.read(key).should be_nil
    end

    it "returns value if key in store" do
      write_key key, 'bar'
      subject.read(key).should eq('bar')
    end
  end

  describe "#delete" do
    it "deletes key" do
      write_key key, 'bar'
      subject.delete(key)
      read_key(key).should be_nil
    end
  end

  describe "#set_add" do
    it "adds value to store" do
      subject.set_add(key, 1)
      read_key(key).should eq(Set[1])
    end

    it "does not add same value more than once" do
      subject.set_add(key, 1)
      subject.set_add(key, 1)
      subject.set_add(key, 1)
      subject.set_add(key, 2)
      read_key(key).should eq(Set[1, 2])
    end
  end

  describe "#set_delete" do
    it "removes value from set if key in store" do
      write_key key, Set[1, 2]
      subject.set_delete(key, 1)
      read_key(key).should eq(Set[2])
    end

    it "works fine if key not in store" do
      subject.set_delete(key, 'bar')
    end
  end

  describe "#set_members" do
    it "defaults to empty set" do
      subject.set_members(key).should eq(Set.new)
    end

    it "returns set if in store" do
      write_key key, Set[1, 2]
      subject.set_members(key).should eq(Set[1, 2])
    end
  end

  it "should work with Flipper.new" do
    Flipper.new(subject).should_not be_nil
  end
end
