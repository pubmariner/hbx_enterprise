require 'spec_helper'

class SpecRenderHelper
  include Sinatra::Templates
  include Padrino::Rendering
  include Padrino::Helpers::RenderHelpers
  
  def settings
    OpenStruct.new({:engine => :haml, :templates => {}, :views => File.join(HbxEnterprise::App.root, "views")})
  end

  def template_cache
    Tilt::Cache.new
  end
end

describe "The enrollee view" do
  let(:render_helper) { SpecRenderHelper.new }
  let(:enrollee) { double(:subscriber? => false) }

  it "should render" do
    expect(render_helper.partial("api/enrollee", {:object => enrollee, :engine => :haml})).not_to be_blank
  end
end
