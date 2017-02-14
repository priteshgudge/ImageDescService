class AddMathMlReplacementMode < ActiveRecord::Migration
  def up
    ["MathML"].each {|mode|  MathReplacementMode.create(:mode => mode) unless MathReplacementMode.exists?(:mode => mode)}  
  end

  def down
  end
end
