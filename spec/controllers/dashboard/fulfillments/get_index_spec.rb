require "rails_helper"

RSpec.describe Dashboard::FulfillmentsController do
  describe "GET #index" do
    context "format js" do
      before(:each) do
        @line_item = build_stubbed(:line_item)
        stub_find_line_item(@line_item)

        logged_in_user = create(:identity)
        log_in_dashboard_identity(obj: logged_in_user)
        xhr :get, :index, line_item_id: @line_item.id
      end

      it "should assign LineItem from params[:line_item_id] to @line_item" do
        expect(assigns(:line_item)).to eq(@line_item)
      end

      it { is_expected.to render_template "dashboard/fulfillments/index" }
      it { is_expected.to respond_with :ok }
    end

    context "format json" do
      before(:each) do
        @line_item = build_stubbed(:line_item)
        @fulfillments = instance_double(ActiveRecord::Relation)
        allow(@line_item).to receive(:fulfillments).and_return(@fulfillments)
        stub_find_line_item(@line_item)

        logged_in_user = create(:identity)
        log_in_dashboard_identity(obj: logged_in_user)
        get :index, line_item_id: @line_item.id, format: :json
      end

      it "should assign LineItem from params[:line_item_id] to @line_item" do
        expect(assigns(:line_item)).to eq(@line_item)
      end

      it "should assign Fulfillments of LineItem to @fulfillments" do
        expect(assigns(:fulfillments)).to eq(@fulfillments)
      end

      it { is_expected.to render_template "dashboard/fulfillments/index" }
      it { is_expected.to respond_with :ok }
    end

    def stub_find_line_item(obj)
      allow(LineItem).to receive(:find).
        with(obj.id.to_s).
        and_return(obj)
      allow(LineItem).to receive(:find).
        with(obj.id).
        and_return(obj)
    end
  end
end
