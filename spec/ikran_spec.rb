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
    @reader.exec("server #{server}").should == "remote set to #{@reader.remote}"
  end

  it "should return current remote server on 'server' command without any parameters" do
    server = 'example.com'
    @reader.exec("server #{server}")
    @reader.exec("server").should == "current remote is #{@reader.remote}"
  end

  it "should accept only valid url for server command" do
    # port can't be string
    @reader.exec("server http://example.com:foo").should == "invalid url"
  end

  it "should show error on non-existing command" do
    @reader.exec("foo").should == "command doesn't exist"
  end

  context "ping command" do
    it "should require remote to be set if executing ping without parameters" do
      @reader.exec("ping").should == "remote must be set before executing ping without parameters"
    end

    context "testing availability" do
      it "should return 'server is alive' if server is available" do
        Ping.stub!(:pingecho).and_return(true)
        @reader.exec("server example.com")
        @reader.exec("ping").should == "#{@reader.remote} is alive"
      end

      it "should return 'server is unreachable' if server is unreachable" do
        Ping.stub!(:pingecho).and_return(false)
        @reader.exec("server example.com")
        @reader.exec("ping").should == "#{@reader.remote} is unreachable"
      end
    end
  end

  context "server is example.com" do
    before :all do

    end

    context "non verbose mod" do
      it "should send a HEAD request to given url on 'head' command" do
        @reader = Ikran::Reader.new
        @reader.exec("server example.com")
        @reader.exec("head").should == "200 OK"
      end

    end

  end

  it "should send a GET request to given url on 'get' command"
  it "should send a POST request to given url on 'post' command"
end
