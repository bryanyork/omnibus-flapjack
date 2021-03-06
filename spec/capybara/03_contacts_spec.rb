require 'capybara_spec_helper'

describe  "Contact Management", :type => :feature do
  before :all do
    Bundler.clean_system('PATH=/opt/flapjack/bin:$PATH; flapjack simulate fail --check bacon -i 1 -t 0.1')
  end

  NAME = {
    :first_name => 'Test',
    :last_name => 'Guy'
  }

  MEDIA = {
    :email  => 'testguy@test.com',
    :jabber => 'testguy@jabber.org'
  }

  ENTITY = {
    :name  => 'foo-app-01',
    :check => 'eggs'
  }

  it "Add contact" do
    visit '/edit_contacts'
    click_button 'Add contact'

    fill_in('contact_first_name', :with => NAME[:first_name])
    fill_in('contact_last_name', :with => NAME[:last_name])

    click_button 'Create'

    wait_for_ajax

    NAME.values.each { |v| expect(page).to have_content v }
  end

  it "Adds media to contact" do
    visit '/edit_contacts'

    wait_for_ajax

    first('tr.contact_list_item').hover
    first(:css, ".btn.btn-default.contact-media", :visible => false).click

    content = [ 'Email', 'Jabber', 'SMS', 'Address', 'Interval' ]
    content.each { |c| expect(page).to have_content c }

    # Add some test content
    find('#Email-address').set MEDIA[:email]
    find('#Jabber-address').set MEDIA[:jabber]

    wait_for_ajax

    first(:css, ".close", :visible => false).click
  end

  unless ENV['FF'].nil?
    it "Adds entity to contact" do
      visit '/edit_contacts'

      wait_for_ajax

      first('tr.contact_list_item').hover
      first(:css, ".btn.btn-default.contact-entities", :visible => false).click

      find(".select2-offscreen").click
      find(".select2-drop li", text: 'foo-app-01').click
      click_button 'Add Entities'

      wait_for_ajax

      within(:css, '#contactEntityList') do
        expect(page).to have_content 'foo-app-01'
      end
    end

    it "Checks media and entity were added to contact" do
      visit '/contacts'
      click_link "#{NAME[:first_name]} #{NAME[:last_name]}"

      wait_for_ajax

      content = [ 'email', 'jabber', 'Media', 'Address', 'Interval',
        'Contact Media', 'Summary Mode', 'Summary Threshold', 'Notification Rules'
      ]
      NAME.values.each { |v| content.push v }
      ENTITY.values.each { |v| content.push v }
      MEDIA.values.each { |v| content.push v }

      content.each { |c| expect(page).to have_content c }

      visit '/check?entity=foo-app-01&check=eggs'
      wait_for_ajax
      NAME.values.each { |c| expect(page).to have_content c }
      MEDIA.keys.each { |k| expect(page).to have_content k.capitalize }
    end
  end

  it "Delete contact" do
    visit '/edit_contacts'

    wait_for_ajax

    first('tr.contact_list_item').hover
    first(:css, ".btn.btn-danger.delete-contact", :visible => false).click

    NAME.values.each { |v| expect(page).not_to have_content v }
  end
end
