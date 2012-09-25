require 'net/http'
require 'json'

module Wf4Ever
  class TransformationClient

    # Returns URI of job for future checking
    def self.create_job(uri, resource, format, ro, token)
      uri = URI(uri)
      job_uri = nil
      Net::HTTP.start(uri.host, uri.port || 80) do |http|
        body = {
          "resource" => resource,
          "format" => format,
          "ro" => ro,
          "token" => token
        }.to_json

        headers = {"content-type" => "application/json"}

        response = http.post(uri.request_uri, body, headers)

        if response.code == "201"
          job_uri = response["Location"] || response["location"]
        else
          raise "#{response.code} #{response.body}"
        end
      end
      job_uri
    end

    # Returns status of job
    def self.check_job(uri)
      uri = URI(uri)
      Net::HTTP.start(uri.host, uri.port || 80) do |http|

        response = http.get(uri.request_uri)

        if response.code == "200"
          response_body = JSON.parse(response.body)
          response_body["status"]
        else
          raise "#{response.code} #{response.body}"
        end
      end
    end

    # Cancels job and returns true
    def self.cancel_job(uri)
      uri = URI(uri)
      Net::HTTP.start(uri.host, uri.port || 80) do |http|

        response = http.delete(uri.request_uri)

        if response.code == "204"
          true
        else
          raise "#{response.code} #{response.body}"
        end
      end
    end
  end
end

