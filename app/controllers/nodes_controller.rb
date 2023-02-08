# frozen_string_literal: true

class NodesController < ApplicationController
  before_action :set_node, only: %i[show edit update destroy]

  # GET /nodes or /nodes.json
  def index
    @nodes = Node.all
  end

  # GET /nodes/1 or /nodes/1.json
  def show; end

  # GET /nodes/new
  def new
    @node = Node.new
  end

  # GET /nodes/1/edit
  def edit; end

  # POST /nodes or /nodes.json
  def create
    @node = Node.new(node_params)

    respond_to do |format|
      if @node.save
        format.html { redirect_to node_url(@node), notice: 'Node was successfully created.' }
        format.json { render :show, status: :created, location: @node }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nodes/1 or /nodes/1.json
  def update
    respond_to do |format|
      if @node.update(node_params)
        format.html { redirect_to node_url(@node), notice: 'Node was successfully updated.' }
        format.json { render :show, status: :ok, location: @node }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nodes/1 or /nodes/1.json
  def destroy
    @node.destroy

    respond_to do |format|
      format.html { redirect_to nodes_url, notice: 'Node was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def common_ancestor
    render json: Node.common_ancestor(params['a'].to_i, params['b'].to_i, params['method'].to_i)
  end

  def nodes_birds
    if params['node_ids']
      clean_node_ids = params['node_ids'].map(&:to_i).compact
      render json: Node.nodes_birds(clean_node_ids, params['method'])
    else
      render json: { data: {}, meta: {} }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_node
    @node = Node.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def node_params
    params.require(:node).permit(:id, :parent_id)
  end
end
