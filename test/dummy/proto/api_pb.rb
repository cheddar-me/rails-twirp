# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: api.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("api.proto", :syntax => :proto3) do
    add_message "dummy.api.PingRequest" do
      optional :name, :string, 1
    end
    add_message "dummy.api.PingResponse" do
      optional :double_name, :string, 2
    end
  end
end

module RPC
  module DummyAPI
    PingRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dummy.api.PingRequest").msgclass
    PingResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dummy.api.PingResponse").msgclass
  end
end
