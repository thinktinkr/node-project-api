# frozen_string_literal: true

require 'test_helper'

class BirdsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @node1 = Node.create(id: 10)
    @node2 = Node.create(id: 20)
    @bird = birds(:one)
  end

  def teardown
    Node.delete(@node1.id)
    Node.delete(@node2.id)
  end

  test 'should get index' do
    get birds_url
    assert_response :success
  end

  test 'should get new' do
    get new_bird_url
    assert_response :success
  end

  test 'should create bird' do
    assert_difference('Bird.count') do
      post birds_url, params: { bird: { id: 3, node_id: @node1.id } }
    end

    assert_redirected_to bird_url(Bird.last)
  end

  test 'should show bird' do
    get bird_url(@bird)
    assert_response :success
  end

  test 'should get edit' do
    get edit_bird_url(@bird)
    assert_response :success
  end

  test 'should update bird' do
    patch bird_url(@bird), params: { bird: { node_id: @node2.id } }
    assert_redirected_to bird_url(@bird)
  end

  test 'should destroy bird' do
    assert_difference('Bird.count', -1) do
      delete bird_url(@bird)
    end

    assert_redirected_to birds_url
  end
end
