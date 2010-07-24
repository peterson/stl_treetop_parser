require 'treetop'
require 'stl'
require 'ap'

describe "STL treetop parser" do
  before do
    @p = STLParser.new
  end
  
  describe "solid with no facets" do
    it "should parse an anonymous solid" do
      result = @p.parse("solid \nendsolid \n")
      result.should_not be_nil
      result.solid_start.text_value.should == "solid "
      result.solid_start.solid_name.text_value.should == ""
      result.solid_end.text_value.should == "endsolid "
    end

    it "should handle EOF on last line" do
      result = @p.parse("solid \nendsolid ")
      result.should_not be_nil
      result.solid_start.solid_name.text_value.should == ""
    end

    it "should parse a named solid" do
      result = @p.parse("solid name\nendsolid name\n")
      result.should_not be_nil
      result.solid_start.solid_name.text_value.should == "name"
      result.solid_end.solid_name.text_value.should == "name"
    end

    it "should have no facets" do
      result = @p.parse("solid name\nendsolid name\n")
      result.should_not be_nil
      result.facet.text_value.should == ""
    end
  end

  describe "named solid with one facet but no outer loop" do
    it "should parse facet" do
      result = @p.parse("solid onefacet\nfacet normal -1.0 0.0 1.0\nendfacet\nendsolid onefacet")
      result.should_not be_nil
      facet = result.facet.elements[0]
      facet.text_value.should_not be_nil
      facet.facet_start.ni.text_value.should == "-1.0"
      facet.facet_start.nj.text_value.should == "0.0"
      facet.facet_start.nk.text_value.should == "1.0"
      facet.outer_loop.text_value.should == ""
    end
  end

  describe "named solid with one facet and an outer loop" do
    it "should parse outer loop with no vertices" do
      result = @p.parse("solid onefacet\nfacet normal -1.0 0.0 1.0\n  outer loop\nendloop\nendfacet\nendsolid onefacet")
      result.should_not be_nil
      facet = result.facet.elements[0]
      facet.text_value.should_not be_nil
      facet.facet_start.ni.text_value.should == "-1.0"
      facet.facet_start.nj.text_value.should == "0.0"
      facet.facet_start.nk.text_value.should == "1.0"
      facet.outer_loop.text_value.should_not == ""
      facet.outer_loop.text_value.should == "outer loop\nendloop\n"
    end

    it "should parse single vertex in outer loop" do
      result = @p.parse("solid onefacet\nfacet normal -1.0 0.0 1.0\n  outer loop\n    vertex -1.0 0.0 1.0\nendloop\nendfacet\nendsolid onefacet")
      result.should_not be_nil
      facet = result.facet.elements[0]
      facet.outer_loop.vertex.text_value.should == "vertex -1.0 0.0 1.0\n"
      facet.outer_loop.vertex.elements[0].vx.text_value.should == "-1.0"
      facet.outer_loop.vertex.elements[0].vy.text_value.should == "0.0"
      facet.outer_loop.vertex.elements[0].vz.text_value.should == "1.0"
    end

    it "should parse multiple vertices in outer loop" do
      result = @p.parse("solid onefacet\nfacet normal -1.0 0.0 1.0\n  outer loop\n    vertex -1.0 0.0 1.0\n    vertex -2.0 0.0 2.0\nendloop\nendfacet\nendsolid onefacet")
      result.should_not be_nil
      facet = result.facet.elements[0]
      facet.outer_loop.vertex.text_value.should == "vertex -1.0 0.0 1.0\n    vertex -2.0 0.0 2.0\n"
      facet.outer_loop.vertex.elements[0].vx.text_value.should == "-1.0"
      facet.outer_loop.vertex.elements[0].vy.text_value.should == "0.0"
      facet.outer_loop.vertex.elements[0].vz.text_value.should == "1.0"
      facet.outer_loop.vertex.elements[1].vx.text_value.should == "-2.0"
      facet.outer_loop.vertex.elements[1].vy.text_value.should == "0.0"
      facet.outer_loop.vertex.elements[1].vz.text_value.should == "2.0"
    end
  end
  
  describe "named solid with multiple facets" do
    it "should parse" do
      stl_doc = <<-STL
        solid rect
        facet normal 0.0 0.0 -1.0
           outer loop
              vertex 116.377952755906 66.1023622047244 0.0
              vertex 0.0 0.0 0.0
              vertex 0.0 66.1023622047244 0.0
           endloop
        endfacet
        facet normal 0.0 0.0 -1.0
           outer loop
              vertex 0.0 0.0 0.0
              vertex 116.377952755906 116.377952755906 0.0
              vertex 116.377952755906 0.0 0.0
           endloop
        endfacet
        endsolid rect
      STL
      result = @p.parse(stl_doc)
      result.should_not be_nil
      facets = result.facet.elements
      facets[0].text_value.should_not be_nil
      facets[0].facet_start.ni.text_value.should == "0.0"
      facets[0].facet_start.nj.text_value.should == "0.0"
      facets[0].facet_start.nk.text_value.should == "-1.0"
      facets[0].outer_loop.vertex.elements[0].vx.text_value.should == "116.377952755906"
      facets[0].outer_loop.vertex.elements[0].vy.text_value.should == "66.1023622047244"
      facets[0].outer_loop.vertex.elements[0].vz.text_value.should == "0.0"
      facets[0].outer_loop.vertex.elements[1].vx.text_value.should == "0.0"
      facets[0].outer_loop.vertex.elements[1].vy.text_value.should == "0.0"
      facets[0].outer_loop.vertex.elements[1].vz.text_value.should == "0.0"
      facets[0].outer_loop.vertex.elements[2].vx.text_value.should == "0.0"
      facets[0].outer_loop.vertex.elements[2].vy.text_value.should == "66.1023622047244"
      facets[0].outer_loop.vertex.elements[2].vz.text_value.should == "0.0"
      facets[1].text_value.should_not be_nil
      facets[1].facet_start.ni.text_value.should == "0.0"
      facets[1].facet_start.nj.text_value.should == "0.0"
      facets[1].facet_start.nk.text_value.should == "-1.0"
      facets[1].outer_loop.vertex.elements[0].vx.text_value.should == "0.0"
      facets[1].outer_loop.vertex.elements[0].vy.text_value.should == "0.0"
      facets[1].outer_loop.vertex.elements[0].vz.text_value.should == "0.0"
      facets[1].outer_loop.vertex.elements[1].vx.text_value.should == "116.377952755906"
      facets[1].outer_loop.vertex.elements[1].vy.text_value.should == "116.377952755906"
      facets[1].outer_loop.vertex.elements[1].vz.text_value.should == "0.0"
      facets[1].outer_loop.vertex.elements[2].vx.text_value.should == "116.377952755906"
      facets[1].outer_loop.vertex.elements[2].vy.text_value.should == "0.0"
      facets[1].outer_loop.vertex.elements[2].vz.text_value.should == "0.0"
    end
  end
end
