
require 'spec_helper'

describe Qt::Commander::Creator do
  
  its(:config_dir) { should be_a String }
  its(:config_ini) { should be_a String }
  
  its(:ini)        { should be_an IniFile }
  
  its(:toolchains) {
    subject.toolchains.each { |x|
      x.should be_a Qt::Commander::Creator::Toolchain
    }
  }
  
  its(:versions) {
    subject.versions.each { |x|
      x.should be_a Qt::Commander::Creator::Version
    }
  }
  
  its(:profiles) {
    subject.profiles.each { |x|
      x.should be_a Qt::Commander::Creator::Profile
    }
    subject.profiles.map(&:toolchain).each { |x|
      subject.toolchains.should include x
    }
    subject.profiles.map(&:version).each { |x|
      subject.versions.should include x
    }
    subject.profiles.select(&:android?).each { |x|
      x.toolchain.should be_android
      x.toolchain.android_ndk_tc_version.should be
    }
  }
  
end
