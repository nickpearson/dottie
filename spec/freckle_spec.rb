require 'spec_helper'

describe Dottie::Freckle do
  
  describe 'instantiation' do
    
    it 'creates a Dottie::Freckle from a Hash' do
      expect(Dottie::Freckle.new({ 'a' => 'b' })).to be_a Dottie::Freckle
    end
    it 'creates a Dottie::Freckle from an Array' do
      expect(Dottie::Freckle.new(['a', 'b', 'c'])).to be_a Dottie::Freckle
    end
    ['a', nil, 1].each do |val|
      it "fails to create a Dottie::Freckle from an invalid type (#{val.class})" do
        expect{ Dottie::Freckle.new(val) }.to raise_error(TypeError)
      end
    end
    
  end
  
  describe 'general' do
    
    context 'Hash' do
      let(:freckle) { Dottie::Freckle.new({ 'a' => 'b' }) }
      
      it 'makes the original Hash accessible' do
        expect(freckle.hash).to eq({ 'a' => 'b' })
      end
      it 'makes the original Hash accessible' do
        expect(freckle.wrapped_object).to eq({ 'a' => 'b' })
      end
      it 'raises an error if the wrong type is requested' do
        expect{ freckle.array }.to raise_error TypeError
      end
    end
    
    context 'Array' do
      let(:freckle) { Dottie::Freckle.new([1, 2]) }
      
      it 'makes the original Array accessible' do
        expect(freckle.array).to eq([1, 2])
      end
      it 'makes the original Array accessible' do
        expect(freckle.wrapped_object).to eq([1, 2])
      end
      it 'raises an error if the wrong type is requested' do
        expect{ freckle.hash }.to raise_error TypeError
      end
    end
    
  end
  
  describe 'reading' do
    
    context 'simple' do
      let(:freckle) { Dottie::Freckle.new({ 'a' => 'b', 'c' => { 'd' => 'e' } }) }
      
      it 'reads a standard key' do
        expect(freckle['a']).to eq 'b'
      end
      it 'returns nil for a missing standard key' do
        expect(freckle['d']).to be_nil
      end
      it 'reads a dotted key' do
        expect(freckle['c.d']).to eq 'e'
      end
      it 'returns nil for a missing dotted key' do
        expect(freckle['c.e']).to be_nil
      end
      it 'returns nil for a missing nested dotted key' do
        expect(freckle['c.e.g.x.y']).to be_nil
      end
    end
    
    context 'ending array indexes' do
      let(:freckle) { Dottie::Freckle.new({ 'a' => 'b', 'c' => %w( d e f ) }) }
      
      it 'reads an integer key' do
        expect(freckle['c[0]']).to eq 'd'
      end
      it 'reads a negative integer key' do
        expect(freckle['c[-1]']).to eq 'f'
      end
      it 'reads a named key (first)' do
        expect(freckle['c[first]']).to eq 'd'
      end
      it 'reads a named key (last)' do
        expect(freckle['c[last]']).to eq 'f'
      end
      it 'returns nil for a missing index' do
        expect(freckle['c[4]']).to be_nil
      end
      it 'returns nil for a missing array' do
        expect(freckle['x[4]']).to be_nil
      end
    end
    
    context 'middle array indexes' do
      let(:freckle) { Dottie::Freckle.new({ 'a' => 'b', 'c' => [{ 'd' => 'e' }, { 'f' => 'g' }] }) }
      
      it 'reads an integer key' do
        expect(freckle['c[0].d']).to eq 'e'
      end
      it 'reads a negative integer key' do
        expect(freckle['c[-1].f']).to eq 'g'
      end
      it 'reads a named key (first)' do
        expect(freckle['c[first].d']).to eq 'e'
      end
      it 'reads a named key (last)' do
        expect(freckle['c[last].f']).to eq 'g'
      end
      it 'returns nil for a missing index' do
        expect(freckle['c[4].r']).to be_nil
      end
      it 'returns nil for a missing array' do
        expect(freckle['x[4].s']).to be_nil
      end
    end
    
    context 'consecutive array indexes' do
      let(:freckle) { Dottie::Freckle.new({ 'a' => 'b', 'c' => [ [{}, { 'd' => 'e' }] ] }) }
      
      it 'reads an integer key' do
        expect(freckle['c[0][1].d']).to eq 'e'
      end
      it 'reads a negative integer key' do
        expect(freckle['c[-1][1].d']).to eq 'e'
      end
      it 'reads a named key (first)' do
        expect(freckle['c[first][last].d']).to eq 'e'
      end
      it 'reads a named key (last)' do
        expect(freckle['c[last][last].d']).to eq 'e'
      end
      it 'returns nil for a missing index' do
        expect(freckle['c[4][5]']).to be_nil
      end
      it 'returns nil for a missing array' do
        expect(freckle['x[4][5]']).to be_nil
      end
    end
    
  end
  
  describe 'key existence' do
    let(:freckle) { Dottie::Freckle.new({ 'a' => 'b', 'c' => { 'd' => ['e', 'f', 'g'] } }) }
    
    it "finds a standard key" do
      expect(freckle.has_key?('a')).to be_true
    end
    it "does not find a missing standard key" do
      expect(freckle.has_key?('x')).to be_false
    end
    it "finds a Dottie key (Hash value)" do
      expect(freckle.has_key?('c.d')).to be_true
    end
    it "finds a Dottie key (Array element)" do
      expect(freckle.has_key?('c.d[0]')).to be_true
    end
    it "does not find a missing Dottie key (first part is a String)" do
      expect(freckle.has_key?('a.b')).to be_false
    end
    it "does not find a missing Dottie key (first part exists)" do
      expect(freckle.has_key?('c.x')).to be_false
    end
    it "does not find a missing Dottie key (outside Array bounds)" do
      expect(freckle.has_key?('c.d[4]')).to be_false
    end
    it "does not find a missing Dottie key (no part exists)" do
      expect(freckle.has_key?('x.y')).to be_false
    end
  end
  
  describe 'fetching' do
    let(:freckle) { Dottie::Freckle.new({ 'a' => 'b', 'c' => { 'd' => ['e', 'f', 'g'] } }) }
    
    context 'no default' do
      it 'fetches a standard key' do
        expect(freckle.fetch('a')).to eq 'b'
      end
      it 'fetches a Dottie key (Hash value)' do
        expect(freckle.fetch('c.d')).to eq ['e', 'f', 'g']
      end
      it 'fetches a Dottie key (Array element)' do
        expect(freckle.fetch('c.d[1]')).to eq 'f'
      end
      it 'raises on a missing standard key' do
        expect{ freckle.fetch('x') }.to raise_error KeyError
      end
      it 'raises on a missing Dottie key' do
        expect{ freckle.fetch('x.y') }.to raise_error KeyError
      end
    end
    
    context 'with default' do
      it 'fetches a standard key' do
        expect(freckle.fetch('a', 'z')).to eq 'b'
      end
      it 'fetches a Dottie key' do
        expect(freckle.fetch('c.d', 'z')).to eq ['e', 'f', 'g']
      end
      it 'returns a default for a missing standard key' do
        expect(freckle.fetch('x', 'z')).to eq 'z'
      end
      it 'returns a default for a missing Dottie key' do
        expect(freckle.fetch('x', 'z')).to eq 'z'
      end
    end
    
    context 'with block' do
      it 'fetches a standard key' do
        expect(freckle.fetch('a'){ |key| key.upcase }).to eq 'b'
      end
      it 'fetches a Dottie key' do
        expect(freckle.fetch('c.d'){ |key| key.upcase }).to eq ['e', 'f', 'g']
      end
      it 'yields to a block for a missing standard key' do
        expect(freckle.fetch('x'){ |key| key.upcase }).to eq 'X'
      end
      it 'yields to a block for a missing Dottie key' do
        expect(freckle.fetch('x.y'){ |key| key.upcase }).to eq 'X.Y'
      end
    end
    
  end
  
  describe 'writing' do
    
    context 'simple' do
      before :each do
        @freckle = Dottie::Freckle.new({ 'a' => 'b', 'c' => { 'd' => 'e' } })
      end
      
      it 'overwrites a standard key' do
        @freckle['a'] = 'x'
        expect(@freckle.hash).to eq({ 'a' => 'x', 'c' => { 'd' => 'e' } })
      end
      it 'creates a hash at a non-existent standard key' do
        @freckle['y'] = 'z'
        expect(@freckle.hash).to eq({ 'a' => 'b', 'c' => { 'd' => 'e' }, 'y' => 'z' })
      end
      it 'overwrites a dotted key' do
        @freckle['c.d'] = 'm'
        expect(@freckle.hash).to eq({ 'a' => 'b', 'c' => { 'd' => 'm' } })
      end
      it 'creates a hash at a non-existent dotted key' do
        @freckle['n.o'] = 'p'
        expect(@freckle.hash).to eq({ 'a' => 'b', 'c' => { 'd' => 'e' }, 'n' => { 'o' => 'p' } })
      end
    end
    
    context 'array indexes' do
      before :each do
        @freckle = Dottie::Freckle.new({ 'a' => 'b', 'c' => %w( d e f ) })
      end
      
      it 'overwrites an array element (positive index)' do
        @freckle['c[0]'] = 'x'
        expect(@freckle.hash).to eq({ 'a' => 'b', 'c' => ['x', 'e', 'f'] })
      end
      it 'overwrites an array element (negative index)' do
        @freckle['c[-2]'] = 'y'
        expect(@freckle.hash).to eq({ 'a' => 'b', 'c' => ['d', 'y', 'f'] })
      end
      it 'overwrites an array element ("first")' do
        @freckle['c[first]'] = 'm'
        expect(@freckle.hash).to eq({ 'a' => 'b', 'c' => ['m', 'e', 'f'] })
      end
      it 'overwrites an array element ("last")' do
        @freckle['c[last]'] = 'n'
        expect(@freckle.hash).to eq({ 'a' => 'b', 'c' => ['d', 'e', 'n'] })
      end
      it 'creates an array at a non-existent key (positive index)' do
        @freckle['r[0]'] = 's'
        expect(@freckle.hash).to eq({ 'a' => 'b', 'c' => ['d', 'e', 'f'], 'r' => ['s'] })
      end
      it 'creates an array at a non-existent key ("first")' do
        @freckle['r[first]'] = 's'
        expect(@freckle.hash).to eq({ 'a' => 'b', 'c' => ['d', 'e', 'f'], 'r' => ['s'] })
      end
      it 'adds an array element' do
        @freckle['c[3]'] = 'g'
        expect(@freckle.hash).to eq({ 'a' => 'b', 'c' => ['d', 'e', 'f', 'g'] })
      end
    end
    
  end
  
end
