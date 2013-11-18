class ConspectusController < ApplicationController
  def summarize
    # @tree = "Tree"
    # @title = "Gradebook - Bruce Failor"
    my_mte = MteSession.new
    @tree = my_mte.tree
    @title = my_mte.title
  end
end
