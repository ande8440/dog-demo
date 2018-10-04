require 'rails_helper'

RSpec.describe DogsController, type: :controller do
  describe '#index' do

  	context "has little data" do
  		it 'displays recent dogs' do
	      2.times { create(:dog) }
	      get :index
	      expect(assigns(:dogs).size).to eq(2)
	    end
  	end

  	context "has many pages of data" do
  		before(:each) do
  			20.times { create(:dog) }
  		end

  		it 'paginates dogs backend' do
	      get :index
	      expect(assigns(:dogs).size).to eq(WillPaginate.per_page)
	    end

  	end

  end

end
