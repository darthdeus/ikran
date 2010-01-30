require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ikran" do

  before :each do
    @reader = Ikran::Reader.new
  end

  it "should stop expecting input after 'exit' command'" do
    @reader.exec('exit').should == 'exitting ...'
  end

  it "should allow me to set remote server via 'server' command" do
    server = 'example.com'
    @reader.exec("server #{server}").should == "remote set to http://example.com"
  end

  it "should return error if server is not set and 'server' command is invoked without any parameters" do
    @reader.exec("server").should == "remote is not set"
  end

  it "should return current remote server on 'server' command without any parameters" do
    server = 'example.com'
    @reader.exec("server #{server}")
    @reader.exec("server").should == "current remote is http://example.com"
  end

  it "should accept only valid url for server command" do
    # port can't be string
    @reader.exec("server http://example.com:foo").should == "invalid url"
  end

  it "should show error on non-existing command" do
    @reader.exec("foo").should == "command foo doesn't exist"
  end

  context "ping command" do
    it "should require remote to be set if executing ping without parameters" do
      @reader.exec("ping").should == "remote must be set before executing ping without parameters"
    end

    context "testing availability" do
      it "should return 'server is alive' if server is available" do
        Ping.stub!(:pingecho).and_return(true)
        @reader.exec("server example.com")
        @reader.exec("ping").should == "http://example.com is alive"
      end

      it "should return 'server is unreachable' if server is unreachable" do
        Ping.stub!(:pingecho).and_return(false)
        @reader.exec("server example.com")
        @reader.exec("ping").should == "http://example.com is unreachable"
      end
    end
  end

  it "should toggle verbose on 'verbose' command" do
    @reader.exec("verbose").should == "verbose is now ON"
    @reader.exec("verbose").should == "verbose is now OFF"
  end

  it "should require remote to be set before executing 'head' command" do
    @reader.exec("head").should == "remote must be set before executing head"
  end

  context "non verbose mod" do
    it "should send a request to given url on 'head' command" do
      @reader = Ikran::Reader.new
      @reader.exec("server example.com")
      @reader.exec("head").should == "200 OK"
    end
  end

  context "parsing" do
    it "should return entire command if no parameters are passed" do
      @reader.parse("server").should == "server"
    end

    it "should return entire command if only one parameter is passed with quoted parameter" do
      @reader.parse("server first").should == "server 'first'"
    end

    it "should parse and return only first two words in command with quoted parameter" do
      @reader.parse("server first second").should == "server 'first'"
    end

    it "should return nil if command is invalid" do
      @reader.parse("foo").should == nil
    end

  end

end
