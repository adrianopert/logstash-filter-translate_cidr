# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/filters/translate_cidr"

describe LogStash::Filters::Translate_CIDR do
  

  describe "exact translation" do
    config <<-CONFIG
      filter {
        translate_cidr {
          field       => "status"
          destination => "translation"
          dictionary  => [ "200", "OK",
                           "300", "Redirect",
                           "400", "Client Error",
                           "500", "Server Error" ]
          exact       => true
          regex       => false
          cidr        => false
        }
      }
    CONFIG

    sample("status" => 200) do
      insist { subject["translation"] } == "OK"
    end
  end

  describe "multi translation" do
    config <<-CONFIG
      filter {
        translate_cidr {
          field       => "status"
          destination => "translation"
          dictionary  => [ "200", "OK",
                           "300", "Redirect",
                           "400", "Client Error",
                          "500", "Server Error" ]
          exact       => false
          regex       => false
          cidr        => false
        }
      }
    CONFIG

    sample("status" => "200 & 500") do
      insist { subject["translation"] } == "OK & Server Error"
    end
  end

  describe "regex translation" do
    config <<-CONFIG
      filter {
        translate_cidr {
          field       => "status"
          destination => "translation"
          dictionary  => [ "^2[0-9][0-9]$", "OK",
                           "^3[0-9][0-9]$", "Redirect",
                           "^4[0-9][0-9]$", "Client Error",
                           "^5[0-9][0-9]$", "Server Error" ]
          exact       => true
          regex       => true
          cidr        => false
        }
      }
    CONFIG

    sample("status" => "200") do
      insist { subject["translation"] } == "OK"
    end
  end

  describe "cidr translation red" do
    config <<-CONFIG
      filter {
        translate_cidr {
          field       => "ip_SRC"
          destination => "translation"
          dictionary  => [ "192.168.1.0/24", "RED 1",
                           "192.168.5.0/24", "RED 2",
                           "192.168.100.22", "HOST X" ]
          exact       => true
          regex       => false
          cidr        => true
        }
      }
    CONFIG

    sample("ip_SRC" => "192.168.5.1") do
      insist { subject["translation"] } == "RED 2"
    end
  end

  describe "cidr translation host" do
    config <<-CONFIG
      filter {
        translate_cidr {
          field       => "ip_SRC"
          destination => "translation"
          dictionary  => [ "192.168.1.0/24", "RED 1",
                           "192.168.5.0/24", "RED 2",
                           "192.168.100.22", "HOST X" ]
          exact       => true
          regex       => false
          cidr        => true
        }
      }
    CONFIG

    sample("ip_SRC" => "192.168.100.22") do
      insist { subject["translation"] } == "HOST X"
    end
  end

  describe "cidr translation fallback" do
    config <<-CONFIG
      filter {
        translate_cidr {
          field       => "ip_SRC"
          destination => "translation"
          dictionary  => [ "192.168.1.0/24", "RED 1",
                           "192.168.5.0/24", "RED 2",
                           "192.168.100.22", "HOST X" ]
          exact       => true
          regex       => false
          cidr        => true
          fallback => "no match"
        }
      }
    CONFIG

    sample("ip_SRC" => "192.168.2.1") do
      insist { subject["translation"] } == "no match"
    end
  end

  describe "fallback value - static configuration" do
    config <<-CONFIG
      filter {
        translate_cidr {
          field       => "status"
          destination => "translation"
          fallback => "no match"
          cidr        => false
        }
      }
    CONFIG

    sample("status" => "200") do
      insist { subject["translation"] } == "no match"
    end
  end

  describe "fallback value - allow sprintf" do
    config <<-CONFIG
      filter {
        translate_cidr {
          field       => "status"
          destination => "translation"
          fallback => "%{missing_translation}"
          cidr        => false
        }
      }
    CONFIG

    sample("status" => "200", "missing_translation" => "no match") do
      insist { subject["translation"] } == "no match"
    end
  end

end
