
require 'spec_helper'

describe Qt::Commander::Creator do
  
  its(:config_dir) { should be_a String }
  its(:config_ini) { should be_a String }
  
  its(:ini)        { should be_an IniFile }
  its(:toolchains) { should be_an Array }
  
  its('toolchains.first') { should be_a Hash }
  
  it "can select toolchains by match" do
    first = subject.toolchains.first
    
    subject.toolchains(first[:name], first[:target]).should eq [first]
    subject.toolchains(first[:name])                .should eq [first]
    subject.toolchains(first[:target])              .should eq [first]
    subject.toolchain(first[:name], first[:target]) .should eq first
    subject.toolchain(first[:name])                 .should eq first
    subject.toolchain(first[:target])               .should eq first
    
    subject.toolchains(:generic).should_not be_empty
    subject.toolchains(:generic).last.should eq subject.toolchain(:generic)
  end
  
end
