require 'rails_helper'

RSpec.describe Admin::IdentitiesController do
      
  describe 'user is not logged in and, thus, has no access to' do
    it 'index' do
      get(:index, {:format => :html})
      expect(response).to redirect_to("/identities/sign_in")
    end

    it 'search' do
      get(:search, {:term => "abcd", :format => :json})
      expect(response.status).to eq(401)
    end
    
    it 'create' do
      expect {
        post(:create, {:format => :json,
          :identity => {:first_name => "John", :last_name => "Smith", :email => "johnsmith@techu.edu", :ldap_uid => "jsmith@techu.edu"}
        })
        expect(response.status).to eq(401)
      }.to change(Identity, :count).by(0)
    end
    
    it 'show' do 
      get(:show, {:id => 1, :format => :json})
      expect(response.status).to eq(401)
    end
   
    it 'update' do
      put(:update, {:id => 1, :format => :json})
      expect(response.status).to eq(401)
    end
  end

  describe 'authenticated identity' do
    before :each do
      @identity = Identity.new
      @identity.approved = true
      @identity.save(validate: false)
      session[:identity_id] = @identity.id
      # Devise test helper method: sign_in
      sign_in @identity
    end
   
    describe 'is not a service_provider or super_user and, thus,' do
      describe 'should have access to' do
        it 'index' do 
          get(:index, {:format => :html})
          expect(response.status).to eq(200)
          expect(response).to render_template("index")
        end
       
        it 'search' do
          get(:search, {:term => "abcd", :format => :json})
          expect(response.status).to eq(200)
        end
        
        it 'create' do
          expect {
            post(:create, {:format => :json,
              :identity => {:first_name => "John", :last_name => "Smith", :email => "johnsmith@techu.edu", :ldap_uid => "jsmith@techu.edu"}
            })
            expect(response.status).to eq(200)
            new_identity = Identity.where(email: "johnsmith@techu.edu").first
            expect(new_identity.approved).to eq(true)
            expect(new_identity.encrypted_password).not_to be_blank
            expect(JSON.parse(response.body)).to include("id" => new_identity.id, "first_name" => "John", "last_name" => "Smith", 
                                                         "email" => "johnsmith@techu.edu", "ldap_uid" => "jsmith@techu.edu") 
          }.to change(Identity, :count).by(1)
        end
      end
      
      describe 'should NOT have access to' do
        it 'show' do 
          get(:show, {:id => @identity, :format => :json})
          expect(response.status).to eq(401)
        end
       
        it 'update' do
          put(:update, {:id => 1, :format => :json})
          expect(response.status).to eq(401)
        end
      end
    end

    describe 'is a service provider and, thus, should have access to' do
      before :each do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.save(validate: false)
      end
      
      it 'index' do 
        get(:index, {:format => :html})
        expect(response.status).to eq(200)
        expect(response).to render_template("index")
      end
     
      it 'search' do
        get(:search, {:term => "abcd", :format => :json})
        expect(response.status).to eq(200)
      end
      
      it 'create' do
        expect {
          post(:create, {:format => :json,
            :identity => {:first_name => "John", :last_name => "Smith", :email => "johnsmith@techu.edu", :ldap_uid => "jsmith@techu.edu"}
          })
          expect(response.status).to eq(200)
          new_identity = Identity.where(email: "johnsmith@techu.edu").first
          expect(new_identity.approved).to eq(true)
          expect(new_identity.encrypted_password).not_to be_blank
          expect(JSON.parse(response.body)).to include("id" => new_identity.id, "first_name" => "John", "last_name" => "Smith", 
                                                       "email" => "johnsmith@techu.edu", "ldap_uid" => "jsmith@techu.edu") 
        }.to change(Identity, :count).by(1)
      end
    end
    
    describe 'is a super_user and, thus, should have access to' do
      before :each do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.save(validate: false)
      end
      
      it 'index' do 
        get(:index, {:format => :html})
        expect(response.status).to eq(200)
        expect(response).to render_template("index")
      end
     
      it 'search' do
        get(:search, {:term => "abcd", :format => :json})
        expect(response.status).to eq(200)
      end
      
      it 'create' do
        expect {
          post(:create, {:format => :json,
            :identity => {:first_name => "John", :last_name => "Smith", :email => "johnsmith@techu.edu", :ldap_uid => "jsmith@techu.edu"}
          })
          expect(response.status).to eq(200)
          new_identity = Identity.where(email: "johnsmith@techu.edu").first
          expect(new_identity.approved).to eq(true)
          expect(new_identity.encrypted_password).not_to be_blank
          expect(JSON.parse(response.body)).to include("id" => new_identity.id, "first_name" => "John", "last_name" => "Smith", 
                                                       "email" => "johnsmith@techu.edu", "ldap_uid" => "jsmith@techu.edu") 
        }.to change(Identity, :count).by(1)
      end
    end
    
    describe 'is only a catalog_manager and, thus,' do
      before :each do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.save(validate: false)
      end
      
      describe 'should have access to' do
        it 'index' do 
          get(:index, {:format => :html})
          expect(response.status).to eq(200)
          expect(response).to render_template("index")
        end
       
        it 'search' do
          get(:search, {:term => "abcd", :format => :json})
          expect(response.status).to eq(200)
        end
        
        it 'create' do
          expect {
            post(:create, {:format => :json,
              :identity => {:first_name => "John", :last_name => "Smith", :email => "johnsmith@techu.edu", :ldap_uid => "jsmith@techu.edu"}
            })
            expect(response.status).to eq(200)
            new_identity = Identity.where(email: "johnsmith@techu.edu").first
            expect(new_identity.approved).to eq(true)
            expect(new_identity.encrypted_password).not_to be_blank
            expect(JSON.parse(response.body)).to include("id" => new_identity.id, "first_name" => "John", "last_name" => "Smith", 
                                                         "email" => "johnsmith@techu.edu", "ldap_uid" => "jsmith@techu.edu") 
          }.to change(Identity, :count).by(1)
        end
      end
      
      describe 'should NOT have access to' do
        it 'show' do 
          get(:show, {:id => @identity, :format => :json})
          expect(response.status).to eq(401)
        end
       
        it 'update' do
          put(:update, {:id => 1, :format => :json})
          expect(response.status).to eq(401)
        end
      end
    end
  end
end
