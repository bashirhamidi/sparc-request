# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

FactoryGirl.define do
  factory :protocol, aliases: [:project] do
    next_ssr_id                  { Random.rand(10000) }
    short_title                  { Faker::Lorem.word }
    title                        { Faker::Lorem.sentence(3) }
    sponsor_name                 { Faker::Lorem.sentence(3) }
    brief_description            { Faker::Lorem.paragraph(2) }
    indirect_cost_rate           { Random.rand(1000) }
    study_phase                  { Faker::Lorem.word }
    udak_project_number          { Random.rand(1000).to_s }
    funding_rfa                  { Faker::Lorem.word }
    potential_funding_start_date { Time.now + 1.year }
    funding_start_date           { Time.now + 10.day }
    federal_grant_serial_number  { Random.rand(200000).to_s }
    federal_grant_title          { Faker::Lorem.sentence(2) }
    federal_grant_code_id        { Random.rand(1000).to_s }
    federal_non_phs_sponsor      { Faker::Lorem.word }
    federal_phs_sponsor          { Faker::Lorem.word }
    requester_id                 1
    has_cofc                     true

    trait :without_validations do
      to_create { |instance| instance.save(validate: false) }
    end

    trait :funded do
      funding_status "funded"
      funding_source "skrill"
    end

    trait :pending do
      funding_status "pending"
    end

    trait :federal do
      funding_source           "federal"
      potential_funding_source "federal"
    end

    trait :with_sub_service_request_in_cwf do
      after(:create) do |protocol, evaluator|
        service_request = create(:service_request, protocol: protocol)

        SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
        sub_service_request = build(:sub_service_request_in_cwf, service_request: service_request)
        sub_service_request.save validate: false
      end
    end

    transient do
      project_role_count 1
      pi nil
    end

    # TODO: get this to work!
    # after(:build) do |protocol, evaluator|
    #   create_list(:project_role, evaluator.project_role_count,
    #     protocol: protocol, identity: evaluator.pi)
    # end

    after(:build) do |protocol|
      protocol.build_ip_patents_info(attributes_for(:ip_patents_info)) if not protocol.ip_patents_info
      protocol.build_human_subjects_info(attributes_for(:human_subjects_info)) if not protocol.human_subjects_info
      protocol.build_investigational_products_info(attributes_for(:investigational_products_info)) if not protocol.investigational_products_info
      protocol.build_research_types_info(attributes_for(:research_types_info)) if not protocol.research_types_info
      protocol.build_vertebrate_animals_info(attributes_for(:vertebrate_animals_info))  if not protocol.vertebrate_animals_info


    end

    factory :protocol_without_validations, traits: [:without_validations]
    factory :protocol_federally_funded, traits: [:funded, :federal]
    factory :protocol_with_sub_service_request_in_cwf, traits: [:with_sub_service_request_in_cwf, :funded, :federal]
  end

  factory :study, parent: :protocol, class: 'Study' do
    type "Study"
  end
end