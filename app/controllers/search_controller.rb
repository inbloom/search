###############################################################################
# Copyright 2012-2013 inBloom, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################

class SearchController < ApplicationController

  def full_search

    url = 'http://esearch.agilix.com:9200/lr/lr/_search'

    puts "params"
    puts params


    payload = '{"query":{"match":{"targetName":"CCSS.Math.Content.6.EE.A.3"}}}'

    searchResults = RestClient::Request.new( :method => :get, :url => url, :payload => payload ).execute

    respond_to do |format|
      format.json { render json: searchResults }
    end

  end


  # This initial search method just does the raw keyword search and returns the ENTIRE results.
  # All filtering is done on the client side..  This is ONLY for 12/12 release as it will not scale.
  def lri_search
    # The object we return to the UI, if any
    response = []
    # Get our query
    query = params['query']
    unless query.empty?
      # Do a search using the wild card
      searchResults = LriHelper::wildcard_search query
      # If its not empty only return what we directly need
      unless searchResults['response'].empty?
        searchResults['response'].each { |r|
          unless r['props'].empty?
            url = Rack::Utils.unescape(r['props']['urn:lri:property_type:url'].to_s);
            response << {
              'title'             => Rack::Utils.unescape(r['props']['urn:lri:property_type:name'].to_s),
              'url'               => Rack::Utils.unescape(r['props']['urn:lri:property_type:url'].to_s),
              'endUser'           => Rack::Utils.unescape(r['props']['urn:schema-org:property_type:intended_end_user_role'].to_s),
              'ageRange'          => Rack::Utils.unescape(r['props']['urn:schema-org:property_type:typical_age_range'].to_s),
              'educationalUse'    => Rack::Utils.unescape(r['props']['urn:schema-org:property_type:educational_use'].to_s),
              'interactivityType' => Rack::Utils.unescape(r['props']['urn:schema-org:property_type:interactivity_type'].to_s),
              'learningResource'  => Rack::Utils.unescape(r['props']['urn:schema-org:property_type:learning_resource_type'].to_s),
              'mediaType'         => Rack::Utils.unescape(r['props']['urn:schema-org:property_type:physical_media_type'].to_s),
              'groupType'         => Rack::Utils.unescape(r['props']['urn:schema-org:property_type:group_type'].to_s),
              'publisher'         => Rack::Utils.unescape(r['props']['urn:schema-org:property_type:publisher'].to_s),
              'alignments'        => Rack::Utils.unescape(r['props']['urn:schema-org:property_type:alignment_type'].to_s),
              'url2png_token'     => Digest::MD5.hexdigest("?url="+url+"&thumbnail_max_width=160" + 'S86B90B5E2E4AF')
            }
          end
        }
      end
    end

    respond_to do |format|
      format.json { render json: response }
    end

  end

end
