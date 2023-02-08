# frozen_string_literal: true

require 'application_system_test_case'

class BirdsTest < ApplicationSystemTestCase
  setup do
    @bird = birds(:one)
  end

  test 'visiting the index' do
    visit birds_url
    assert_selector 'h1', text: 'Birds'
  end

  test 'should create bird' do
    visit birds_url
    click_on 'New bird'

    fill_in 'Node', with: @bird.node_id
    click_on 'Create Bird'

    assert_text 'Bird was successfully created'
    click_on 'Back'
  end

  test 'should update Bird' do
    visit bird_url(@bird)
    click_on 'Edit this bird', match: :first

    fill_in 'Node', with: @bird.node_id
    click_on 'Update Bird'

    assert_text 'Bird was successfully updated'
    click_on 'Back'
  end

  test 'should destroy Bird' do
    visit bird_url(@bird)
    click_on 'Destroy this bird', match: :first

    assert_text 'Bird was successfully destroyed'
  end
end
