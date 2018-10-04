require 'rails_helper'

describe 'Dog resource', type: :feature do
  before(:all) {@new_images_array = ['spec/fixtures/images/speck.jpg','spec/fixtures/images/speck.jpg','spec/fixtures/images/speck.jpg']}

  it 'can create a profile' do
    visit new_dog_path
    fill_in 'Name', with: 'Speck'
    fill_in 'Description', with: 'Just a dog'
    attach_file 'Image', 'spec/fixtures/images/speck.jpg'
    click_button 'Create Dog'
    expect(Dog.count).to eq(1)
  end

  it 'can upload multiple images for new dog' do
    visit new_dog_path
    fill_in 'Name', with: 'Speck'
    fill_in 'Description', with: 'Just a dog'
    attach_file 'Images', @new_images_array
    click_button 'Create Dog'
    expect(Dog.first.images.count).to eq(@new_images_array.count)
  end

  it 'can be sorted by likes' do
    @user = create(:user)
    @user2 = create(:user)
    login_as(@user2, :scope => :user)
    @dog = create(:dog, owner: @user)
    @dog2 = create(:dog, owner: @user2)

    visit dogs_path
    dog_count = page.all("article.dog-item").count
    expect(dog_count).to eq(2)

    visit dogs_path(sort: 'top', t: 'hour')
    dog_count = page.all("article.dog-item").count
    expect(dog_count).to eq(0)

    @dog.liked_by @user2
    visit dogs_path(sort: 'top', t: 'hour')
    dog_count = page.all("article.dog-item").count
    expect(dog_count).to eq(1)

    visit dogs_path
    dog_count = page.all("article.dog-item").count
    expect(dog_count).to eq(2)
  end

  context 'owner user' do
    before(:each) do
      @user = create(:user)
      login_as(@user, :scope => :user)
      @dog = create(:dog, owner: @user)
    end

    it 'can be associated as owner of dog' do
      expect(@dog.owner).to eq(@user)
    end

    it 'can upload multiple images for existing dog' do
      start_image_count = @dog.images.count
      visit edit_dog_path(@dog)
      attach_file 'Images', @new_images_array
      click_button 'Update Dog'
      expect(@dog.reload.images.count).to eq(start_image_count + @new_images_array.count)
    end

    it 'can edit a dog profile' do
      visit edit_dog_path(@dog)
      fill_in 'Name', with: 'Speck'
      click_button 'Update Dog'
      expect(@dog.reload.name).to eq('Speck')
    end

    it 'can delete a dog profile' do
      visit dog_path(@dog)
      click_link "Delete #{@dog.name}'s Profile"
      expect(Dog.count).to eq(0)
    end

    it 'cannot like own dog' do
      visit dog_path(@dog)
      expect(page).to_not have_link(href: like_dog_path(@dog))
    end
  end

  context 'non-owner user' do
    before(:each) do
      @user = create(:user)
      @user2 = create(:user)
      login_as(@user2, :scope => :user)
      @dog = create(:dog, owner: @user)
    end

    it 'cannot edit other owners dogs'  do
      visit edit_dog_path(@dog)
      expect(current_path).to eq(root_path)
    end

    it 'cannot delete other owners dogs'  do
      visit dog_path(@dog)
      expect(page).to_not have_text("Delete #{@dog.name}'s Profile")
    end

    it 'can like and unlike other dogs' do
      visit dog_path(@dog)
      expect(page).to have_link(href: like_dog_path(@dog))

      @dog.liked_by @user2
      expect(@dog.get_upvotes.size).to eq(1)

      @dog.unliked_by @user2
      expect(@dog.get_upvotes.size).to eq(0)
    end

  end

  context 'non logged in user' do
    before(:each) do
      @user = create(:user)
      @dog = create(:dog, owner: @user)
    end

    it 'cannot edit any dogs'  do
      visit edit_dog_path(@dog)
      expect(current_path).to eq(root_path)
    end

    it 'cannot delete any dogs'  do
      visit dog_path(@dog)
      expect(page).to_not have_text("Delete #{@dog.name}'s Profile")
    end

    it 'cannot like any dogs'  do
      visit dog_path(@dog)
      expect(page).to_not have_link(href: like_dog_path(@dog))
    end

    it 'will be redirected to registration if tries to hit like button'  do
      visit dog_path(@dog)
      expect(page).to have_css("a.like-dog.like-button")
      expect(page).to have_link(href: new_user_registration_path)
    end

  end


  context 'a lot of data for index' do
    n = 20
    before(:each) do 
      n.times { create(:dog) }
    end

    it 'shows pagination bar on index' do
      visit dogs_path
      expect(page).to have_css("div.pagination")
    end

    it 'shows the appropriate amount of ads' do
      visit dogs_path
      dog_count = page.all("article.dog-item").count
      ad_count = page.all(".dog-ad-container").count
      expect(dog_count / $ad_injection_interval).to eq(ad_count)
    end
  end

  context 'little data for index' do
    n = 2
    before(:each) do 
      n.times { create(:dog) }
    end

    it 'does not show pagination bar on index' do
      visit dogs_path
      expect(page).to_not have_css("div.pagination")
    end

  end

  
end
