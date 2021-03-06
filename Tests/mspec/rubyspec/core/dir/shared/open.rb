describe :dir_open, :shared => true do
  it "returns a Dir instance representing the specified directory" do
    dir = Dir.send(@method, DirSpecs.mock_dir)
    dir.class.should == Dir
    dir.close
  end

  it "raises a SystemCallError if the directory does not exist" do
    lambda do
      Dir.send @method, DirSpecs.nonexistent
    end.should raise_error(SystemCallError)
  end

  ruby_version_is "1.9" do
    it "calls #to_path on non-String arguments" do
      p = mock('path')
      p.should_receive(:to_path).and_return(DirSpecs.mock_dir)
      Dir.send(@method, p) { true }
    end
  end

end

describe :dir_open_with_block, :shared => true do
  it "may take a block which is yielded to with the Dir instance" do
    Dir.send(@method, DirSpecs.mock_dir) {|dir| dir.class.should == Dir }
  end

  it "returns the value of the block if a block is given" do
    Dir.open(DirSpecs.mock_dir) {|dir| :value }.should == :value
  end

  it "closes the Dir instance when the block exits if given a block" do
    closed_dir = Dir.send(@method, DirSpecs.mock_dir) { |dir| dir }
    lambda { closed_dir.close }.should raise_error(IOError)
  end

  it "closes the Dir instance when the block exits the block even due to an exception" do
    @closed_dir = nil

    lambda do
      Dir.send(@method, DirSpecs.mock_dir) do |dir|
        @closed_dir = dir
        raise
      end
    end.should raise_error

    lambda { @closed_dir.close }.should raise_error(IOError)
  end
end
