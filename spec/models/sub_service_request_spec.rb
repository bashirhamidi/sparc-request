require 'spec_helper'

describe 'SubServiceRequest' do

  context 'fulfillment' do

    describe 'candidate_services' do

      context 'single core' do

        before :each do
          program = FactoryGirl.create(:program)
          core = FactoryGirl.create(:core, :process_ssrs, parent_id: program.id)
          
          @ppv = FactoryGirl.create(:service, organization_id: core.id) # PPV Service
          @otf = FactoryGirl.create(:service, organization_id: core.id) # OTF Service
          @otf.pricing_maps.build(FactoryGirl.attributes_for(:pricing_map, :is_one_time_fee))

          @ssr = FactoryGirl.create(:sub_service_request, organization_id: core.id)
        end

        it 'should return a list of available services' do
          @ssr.candidate_services.should include(@ppv, @otf)
        end

        it 'should ignore unavailable services' do
          ppv2 = FactoryGirl.create(:service, :disabled, organization_id: @otf.core.id) # Disabled PPV Service
          @ssr.candidate_services.should_not include(ppv2)
        end

      end

      context 'multiple cores' do

        it 'should climb the org tree to get services' do
          program = FactoryGirl.create(:program, :process_ssrs)
          core = FactoryGirl.create(:core, parent_id: program.id)
          core2 = FactoryGirl.create(:core, parent_id: program.id)
          core3 = FactoryGirl.create(:core, parent_id: program.id)
          
          ppv = FactoryGirl.create(:service, organization_id: core.id) # PPV Service
          ppv2 = FactoryGirl.create(:service, :disabled, organization_id: core3.id) # Disabled PPV Service
          otf = FactoryGirl.create(:service, organization_id: core2.id) # OTF Service
          otf.pricing_maps.build(FactoryGirl.attributes_for(:pricing_map, :is_one_time_fee))

          ssr = FactoryGirl.create(:sub_service_request, organization_id: core.id)

          ssr.candidate_services.should include(ppv, otf)
        end

      end

    end

    describe 'fulfillment line item manipulation' do

      let!(:core)                 { FactoryGirl.create(:core) }
      let!(:service)              { FactoryGirl.create(:service, organization_id: core.id, ) }
      let!(:service2)             { FactoryGirl.create(:service, organization_id: core.id) }
      let!(:service_request)      { FactoryGirl.create(:service_request, subject_count: 5, visit_count: 5) }
      let!(:service_request2)     { FactoryGirl.create(:service_request) }
      let!(:sub_service_request)  { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id) }
      let!(:sub_service_request2) { FactoryGirl.create(:sub_service_request, service_request_id: service_request2.id) }
      let!(:pricing_map)          { FactoryGirl.create(:pricing_map, service_id: service.id) }
 
      context 'adding a line item' do
       
        it 'should fail if service is already on the service request' do
          FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id,
            sub_service_request_id: sub_service_request.id)
          lambda { sub_service_request.add_line_item(service) }.should raise_exception
        end

        it 'should have added the line item if successful' do
          sub_service_request.add_line_item(service)
          service_request.line_items.count.should eq(1)
        end
      end

      context 'updating a line item' do

        it 'should fail if the line item is not on the sub service request' do
          FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id,
            sub_service_request_id: sub_service_request.id)
          lambda { sub_service_request2.update_line_item(line_item) }.should raise_exception
        end

        it 'should update the line item successfully' do
          line_item = FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id,
            sub_service_request_id: sub_service_request.id)
          sub_service_request.update_line_item(line_item, quantity: 50)
          line_item.quantity.should eq(50)
        end
      end

      describe 'one time fee manipulation' do

        before :each do
          FactoryGirl.create(:pricing_map, :is_one_time_fee, service_id: service.id)
        end

        it 'should work with one time fees' do
          service.stub!(:is_one_time_fee?).and_return true
          lambda { sub_service_request.add_line_item(service) }.should_not raise_exception
        end
      end

      describe 'per patient per visit manipulation' do

        before :each do
          FactoryGirl.create(:pricing_map, service_id: service2.id)
        end

        context 'adding a line item' do

          it 'should build the visits successfully' do
            sr = ServiceRequest.find(service_request.id)
            sub_service_request.add_line_item(service2)
            sr.line_items.first.visits.count.should eq(service_request.visit_count)
          end
        end
      end
    end

    describe "cost calculations" do

      let!(:core)                 { FactoryGirl.create(:core) }
      let!(:service)              { FactoryGirl.create(:service, organization_id: core.id, ) }
      let!(:service2)             { FactoryGirl.create(:service, organization_id: core.id) }
      let!(:service_request)      { FactoryGirl.create(:service_request, subject_count: 5, visit_count: 5) }
      let!(:service_request2)     { FactoryGirl.create(:service_request) }
      let!(:sub_service_request)  { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id) }
      let!(:sub_service_request2) { FactoryGirl.create(:sub_service_request, service_request_id: service_request2.id) }
      let!(:pricing_map)          { service.pricing_maps[0] }
      let!(:pricing_map2)         { service2.pricing_maps[0] }
      let!(:line_item)            { FactoryGirl.create(:line_item, service_request_id: service_request2.id, sub_service_request_id: sub_service_request2.id,
                                   service_id: service.id) }
      let!(:line_item2)           { FactoryGirl.create(:line_item, service_request_id: service_request.id, sub_service_request_id: sub_service_request.id,
                                   service_id: service.id) }
      let!(:pricing_setup)        { FactoryGirl.create(:pricing_setup, organization_id: core.id) }
      let!(:subsidy)              { FactoryGirl.create(:subsidy, pi_contribution: 250, sub_service_request_id: sub_service_request.id) }
      let!(:subsidy_map)          { FactoryGirl.create(:subsidy_map, organization_id: core.id) }
      
      before :each do
        @protocol = Study.create(FactoryGirl.attributes_for(:protocol))
        @protocol.update_attributes(funding_status: "funded", funding_source: "federal", indirect_cost_rate: 200)
        @protocol.save :validate => false
        service_request.update_attributes(protocol_id: @protocol.id)
        service_request2.update_attributes(protocol_id: @protocol.id)
        pricing_map.update_attributes(is_one_time_fee: true)
        pricing_map2.update_attributes(is_one_time_fee: false)
      end

      context "direct cost total" do

        it "should return the direct cost for services that are one time fees" do
          sub_service_request2.direct_cost_total.should eq(500)
        end

        it "should return the direct cost for services that are visit based" do
          sub_service_request.direct_cost_total.should eq(500)
        end
      end

      context "indirect cost total" do

        it "should return the indirect cost for one time fees" do
          sub_service_request2.indirect_cost_total.should eq(1000)
        end

        it "should return the indirect cost for visit based services" do
          sub_service_request.indirect_cost_total.should eq(1000)
        end
      end

      context "grand total" do

        it "should return the grand total cost of the sub service request" do
          sub_service_request.grand_total.should eq(1500)
        end
      end

      context "subsidy percentage" do

        it "should return the correct subsidy percentage" do
          sub_service_request.subsidy_percentage.should eq(50)
        end
      end

      context "subsidy organization" do

        let!(:institution)  { FactoryGirl.create(:institution) }
        let!(:provider)     { FactoryGirl.create(:provider, parent_id: institution.id) }
        let!(:program)      { FactoryGirl.create(:program, parent_id: provider.id) }
        let!(:subsidy_map2) { FactoryGirl.create(:subsidy_map, organization_id: program.id, max_dollar_cap: 100) }

        it "should return the core if max dollar cap or max percentage is > 0" do
          subsidy_map.update_attributes(max_dollar_cap: 100)
          sub_service_request.subsidy_organization.should eq(core)
        end

        it "should return the institution if the organization is a provider and max dollar cap or percentage is < 0" do
          sub_service_request.update_attributes(organization_id: provider.id)
          subsidy_map.update_attributes(organization_id: provider.id)
          sub_service_request.subsidy_organization.should eq(institution)
        end

        it "should return the parent if the max dollar cap or percentage is < 0" do
          core.update_attributes(parent_id: program.id)
          sub_service_request.subsidy_organization.should eq(program)
        end


      end

      context "eligible for subsidy" do
        
        it "should return true if the organization's max dollar cap is > 0" do
          subsidy_map.update_attributes(max_dollar_cap: 100)
          sub_service_request.eligible_for_subsidy?.should eq(true)
        end

        it "should return true if the organization's max percentage is > 0" do
          subsidy_map.update_attributes(max_percentage: 50)
          sub_service_request.eligible_for_subsidy?.should eq(true)
        end

        it "should return false is organization is excluded from subsidy" do
          subsidy_map.update_attributes(max_dollar_cap: 100)
          excluded_funding_source = FactoryGirl.create(:excluded_funding_source, subsidy_map_id: subsidy_map.id, funding_source: "federal")
          sub_service_request.eligible_for_subsidy?.should eq(false)
        end
      end
    end

    describe "sub service request status" do

      let!(:sub_service_request) { FactoryGirl.create(:sub_service_request) }

      context "can be edited" do

        it "should return true if the status is draft" do
          sub_service_request.update_attributes(status: "draft")
          sub_service_request.can_be_edited?.should eq(true)
        end

        it "should return true if the status is submitted" do
          sub_service_request.update_attributes(status: "submitted")
          sub_service_request.can_be_edited?.should eq(true)
        end

        it "should return true if the status is nil" do
          sub_service_request.update_attributes(status: nil)
          sub_service_request.can_be_edited?.should eq(true)
        end

        it "should return false if status is anything other than above states" do
          sub_service_request.update_attributes(status: "complete")
          sub_service_request.can_be_edited?.should eq(false)
        end
      end

      context "candidate statuses" do

        let!(:ctrc)     { FactoryGirl.create(:provider, is_ctrc: true) }
        let!(:provider) { FactoryGirl.create(:provider) }

        it "should contain 'ctrc approved' and 'ctrc review' if the organization is ctrc" do
          sub_service_request.update_attributes(organization_id: ctrc.id)
          sub_service_request.candidate_statuses.should include('ctrc approved', 'ctrc review')
        end

        it "should not contain ctrc statuses if the organization is not ctrc" do
          sub_service_request.update_attributes(organization_id: provider.id)
          sub_service_request.candidate_statuses.should_not include('ctrc approved', 'ctrc review')
        end 
      end
      
      context "update past status" do

        let!(:past_status) { FactoryGirl.create(:past_status, sub_service_request_id: sub_service_request.id)}

        it "should set sub service request's past status to 'draft' if no previous status" do
          sub_service_request.update_past_status
          sub_service_request.past_statuses.last.status.should eq("draft")
        end
      end
    end

    describe "sub service request ownership" do

      context "candidate owners" do

        let!(:institution)         { FactoryGirl.create(:institution) }
        let!(:provider)            { FactoryGirl.create(:provider, parent_id: institution.id, process_ssrs: true) }
        let!(:core)                { FactoryGirl.create(:core, parent_id: provider.id, process_ssrs: true) }
        let!(:program)             { FactoryGirl.create(:program, parent_id: core.id, process_ssrs: true)}
        let!(:sub_service_request) { FactoryGirl.create(:sub_service_request, organization_id: core.id) }
        let!(:user1)               { FactoryGirl.create(:identity) }
        let!(:user2)               { FactoryGirl.create(:identity) }
        let!(:user3)               { FactoryGirl.create(:identity) }
        let!(:service_provider1)   { FactoryGirl.create(:service_provider, identity_id: user1.id, organization_id: core.id) }
        let!(:service_provider2)   { FactoryGirl.create(:service_provider, identity_id: user2.id, organization_id: provider.id) }
        let!(:service_provider3)   { FactoryGirl.create(:service_provider, identity_id: user3.id, organization_id: program.id) }

        it "should return all identities associated with the sub service request's organization, children, and parents" do
          sub_service_request.candidate_owners.should include(user1, user2, user3)
        end

        it "should not return any identities from child organizations if process ssrs is not set" do
          core.update_attributes(process_ssrs: false)
          sub_service_request.candidate_owners.should_not include(user3)
        end

        it "should return the owner" do
          user = FactoryGirl.create(:identity)
          sub_service_request.update_attributes(owner_id: user.id)
          sub_service_request.candidate_owners.should include(user)
        end

        it "should not return the same identity twice if it is both the owner and service provider" do
          sub_service_request.update_attributes(owner_id: user2.id)
          sub_service_request.candidate_owners.uniq.length.should eq(sub_service_request.candidate_owners.length) 
        end
      end
    end      
  end
end
