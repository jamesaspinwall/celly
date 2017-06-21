#!/usr/bin/env ruby

# DECRYPT

require 'openssl'
require 'base64'

private_key_file = 'private.pem';
password = 'Comlyr257!'

encrypted_string = IO.read('message.rsa')

private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file),password)
string = private_key.private_decrypt(Base64.decode64(encrypted_string))
puts string

